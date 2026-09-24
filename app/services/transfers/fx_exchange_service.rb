# frozen_string_literal: true

module Transfers
  class FxExchangeService
    class QuoteExpiredError < StandardError; end
    class InsufficientFundsError < StandardError; end
    class CurrencyMismatchError < StandardError; end

    def self.call(source_account:, target_account:, quote:)
      new(source_account, target_account, quote).call
    end

    def initialize(source_account, target_account, quote)
      @source_account = source_account
      @target_account = target_account
      @quote = quote
    end

    def call
      ActiveRecord::Base.transaction do
        # 1. Lock the quote record and verify validity
        @quote.lock!
        raise QuoteExpiredError, "Exchange quote has expired. Please refresh rates." unless @quote.active?

        # 2. Verify account currencies match the quote contract
        assert_currency_match!

        # 3. Acquire row-level locks on accounts in deterministic ID order to prevent deadlocks
        accounts = [@source_account, @target_account].sort_by(&:id)
        locked_source = Account.lock("FOR UPDATE").find(@source_account.id)
        locked_target = Account.lock("FOR UPDATE").find(@target_account.id)

        # 4. Verify balance solvency
        if locked_source.balance_cents < @quote.source_amount_subunits
          raise InsufficientFundsError, "Insufficient funds in source account for FX swap."
        end

        # 5. Execute atomic balance updates
        locked_source.update!(
          balance_cents: locked_source.balance_cents - @quote.source_amount_subunits
        )

        locked_target.update!(
          balance_cents: locked_target.balance_cents + @quote.target_amount_subunits
        )

        # 6. Mark quote as executed
        @quote.update!(status: "executed")

        # 7. Record the transfer audit record
        transfer = Transfer.create!(
          from_account: locked_source,
          to_account: locked_target,
          amount_cents: @quote.source_amount_subunits,
          fx_quote: @quote,
          description: "FX Swap: #{@quote.from_currency} to #{@quote.to_currency} at rate #{@quote.effective_rate}",
          status: "completed",
          metadata: {
            fx_quote_id: @quote.id,
            market_rate: @quote.market_rate,
            effective_rate: @quote.effective_rate,
            target_amount_subunits: @quote.target_amount_subunits,
            target_currency: @quote.to_currency,
            fee_subunits: @quote.fee_subunits
          }
        )

        { success: true, transfer: transfer, quote: @quote }
      end
    rescue QuoteExpiredError, InsufficientFundsError, CurrencyMismatchError => e
      Rails.logger.warn("[FxExchangeService] Business logic rejection: #{e.message}")
      { success: false, error: e.message }
    rescue StandardError => e
      Rails.logger.error("[FxExchangeService] Critical failure: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
      raise
    end

    private

    def assert_currency_match!
      unless @source_account.currency == @quote.from_currency && @target_account.currency == @quote.to_currency
        raise CurrencyMismatchError, "Account currencies (#{@source_account.currency}/#{@target_account.currency}) do not match quote (#{@quote.from_currency}/#{@quote.to_currency})"
      end
    end
  end
end
