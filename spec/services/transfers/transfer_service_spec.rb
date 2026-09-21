# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transfers::TransferService do
  let(:alice) { create(:user) }
  let(:bob) { create(:user) }
  let!(:from_account) { create(:account, user: alice, balance_cents: 10_000, currency: "USD", status: "active") }
  let!(:to_account) { create(:account, user: bob, balance_cents: 2_500, currency: "USD", status: "active") }

  describe '.call' do
    subject(:perform_transfer) do
      described_class.call(
        from_account: from_account,
        to_account: to_account,
        amount_cents: amount_cents,
        description: description,
        idempotency_key: idempotency_key
      )
    end

    let(:amount_cents) { 3_000 } # $30.00
    let(:description) { 'Team lunch split' }
    let(:idempotency_key) { 'test-key-123' }

    context 'with valid parameters and sufficient funds' do
      it 'executes the transfer and updates both balances atomically' do
        transfer = perform_transfer

        expect(transfer).to be_persisted
        expect(transfer.status).to eq('completed')
        expect(transfer.amount_cents).to eq(3_000)

        expect(from_account.reload.balance_cents).to eq(7_000)
        expect(to_account.reload.balance_cents).to eq(5_500)
      end

      it 'enqueues a TransferNotificationJob asynchronously' do
        expect { perform_transfer }.to have_enqueued_job(TransferNotificationJob)
      end
    end

    context 'when attempting to transfer more than available balance (overdraft)' do
      let(:amount_cents) { 50_000 } # $500.00 vs $100.00 balance

      it 'raises InsufficientFundsError and does not modify account balances' do
        expect { perform_transfer }.to raise_error(Transfers::InsufficientFundsError, /Insufficient funds/)

        expect(from_account.reload.balance_cents).to eq(10_000)
        expect(to_account.reload.balance_cents).to eq(2_500)
        expect(Transfer.count).to eq(0)
      end
    end

    context 'when the same idempotency key is submitted twice' do
      it 'returns the existing transfer without debiting funds a second time' do
        first_transfer = perform_transfer
        expect(from_account.reload.balance_cents).to eq(7_000)

        # Retry with identical key:
        second_transfer = perform_transfer
        expect(second_transfer.id).to eq(first_transfer.id)
        expect(from_account.reload.balance_cents).to eq(7_000)
        expect(Transfer.count).to eq(1)
      end
    end

    context 'when source account is frozen' do
      before do
        from_account.update!(status: 'frozen')
      end

      it 'raises InvalidTransferError and aborts' do
        expect { perform_transfer }.to raise_error(Transfers::InvalidTransferError, /must be active/)
        expect(from_account.reload.balance_cents).to eq(10_000)
      end
    end

    context 'when destination account is identical to source account' do
      it 'raises InvalidTransferError and aborts' do
        expect {
          described_class.call(
            from_account: from_account,
            to_account: from_account,
            amount_cents: 1_000
          )
        }.to raise_error(Transfers::InvalidTransferError, /Cannot transfer to the same account/)
      end
    end

    context 'when an unexpected exception occurs mid-transaction' do
      before do
        allow(Transfer).to receive(:create!).and_raise(ActiveRecord::StatementInvalid, "Simulated database deadlock")
      end

      it 'rolls back the entire transaction without altering balances' do
        expect { perform_transfer }.to raise_error(ActiveRecord::StatementInvalid)

        expect(from_account.reload.balance_cents).to eq(10_000)
        expect(to_account.reload.balance_cents).to eq(2_500)
        expect(Transfer.count).to eq(0)
      end
    end
  end
end
