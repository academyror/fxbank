# frozen_string_literal: true

module Ledger
  class PostingService
    class UnbalancedJournalError < StandardError; end
    class AccountCurrencyMismatchError < StandardError; end

    def self.post(description:, entries:, reference: nil, posted_at: Time.current)
      new(description, entries, reference, posted_at).execute
    end

    def initialize(description, entries, reference, posted_at)
      @description = description
      @entries_data = entries # Array of { account:, entry_type:, amount_subunits: }
      @reference = reference
      @posted_at = posted_at
    end

    def execute
      validate_zero_sum_balance!

      ActiveRecord::Base.transaction do
        journal = LedgerJournal.create!(
          description: @description,
          reference_type: @reference&.class&.name,
          reference_id: @reference&.id&.to_s,
          posted_at: @posted_at,
          status: "posted"
        )

        @entries_data.each do |data|
          account = data[:account]
          entry_type = data[:entry_type].to_s.downcase
          amount = Integer(data[:amount_subunits])

          if data[:currency].present? && data[:currency] != account.currency
            raise AccountCurrencyMismatchError, "Entry currency does not match account currency"
          end

          LedgerEntry.create!(
            ledger_journal: journal,
            ledger_account: account,
            entry_type: entry_type,
            amount_subunits: amount,
            currency: account.currency
          )

          # Update cached balance according to account normal balance
          update_account_cache!(account, entry_type, amount)
        end

        journal
      end
    end

    private

    def validate_zero_sum_balance!
      sums_by_currency = Hash.new { |h, k| h[k] = { debit: 0, credit: 0 } }

      @entries_data.each do |e|
        curr = e[:account].currency
        sums_by_currency[curr][e[:entry_type].to_sym] += Integer(e[:amount_subunits])
      end

      sums_by_currency.each do |curr, totals|
        if totals[:debit] != totals[:credit]
          raise UnbalancedJournalError, "Journal unbalanced for #{curr}: Debits (#{totals[:debit]}) != Credits (#{totals[:credit]})"
        end
      end
    end

    def update_account_cache!(account, entry_type, amount)
      # Normal balances: Assets & Expenses increase on Debit; Liabilities, Equity & Revenue increase on Credit
      delta = if %w[asset expense].include?(account.account_type)
                entry_type == "debit" ? amount : -amount
              else
                entry_type == "credit" ? amount : -amount
              end

      account.lock!
      account.update!(cached_balance_subunits: account.cached_balance_subunits + delta)
    end
  end
end
