# frozen_string_literal: true

module Transfers
  class TransferError < StandardError; end
  class InsufficientFundsError < TransferError; end
  class InvalidTransferError < TransferError; end

  class TransferService
    def self.call(from_account:, to_account:, amount_cents:, description: nil, idempotency_key: nil)
      new(from_account, to_account, amount_cents, description, idempotency_key).execute
    end

    def initialize(from_account, to_account, amount_cents, description, idempotency_key)
      @from_account = from_account
      @to_account = to_account
      @amount_cents = amount_cents.to_i
      @description = description
      @idempotency_key = idempotency_key
    end

    def execute
      validate_transfer!

      ActiveRecord::Base.transaction do
        # 1. Idempotency check: Return existing transfer if already completed
        if @idempotency_key.present?
          existing_transfer = Transfer.find_by(idempotency_key: @idempotency_key)
          return existing_transfer if existing_transfer.present?
        end

        # 2. Deadlock prevention: Always lock accounts in deterministic ID order
        accounts_to_lock = [@from_account, @to_account].sort_by(&:id)
        accounts_to_lock.each(&:lock!)

        # 3. Reload state after acquiring lock to read true committed balance
        @from_account.reload
        @to_account.reload

        # 4. Check business rules and fail loudly if violated
        unless @from_account.status == "active" && @to_account.status == "active"
          raise InvalidTransferError, "Both accounts must be active to transfer"
        end

        if @from_account.balance_cents < @amount_cents
          raise InsufficientFundsError, "Insufficient funds in source account"
        end

        # 5. Mutate balances atomically
        @from_account.update!(balance_cents: @from_account.balance_cents - @amount_cents)
        @to_account.update!(balance_cents: @to_account.balance_cents + @amount_cents)

        # 6. Create immutable audit record
        transfer = Transfer.create!(
          from_account: @from_account,
          to_account: @to_account,
          amount_cents: @amount_cents,
          status: "completed",
          description: @description,
          idempotency_key: @idempotency_key
        )
      end

      # 7. Dispatch asynchronous notification worker
      begin
        TransferNotificationJob.perform_later(transfer.id)
      rescue StandardError => e
        Rails.logger.warn("[TransferService] Could not enqueue notification: #{e.message}")
      end

      transfer
    end

    private

    def validate_transfer!
      raise InvalidTransferError, "Transfer amount must be greater than zero" unless @amount_cents.positive?
      raise InvalidTransferError, "Cannot transfer to the same account" if @from_account.id == @to_account.id
    end
  end
end
