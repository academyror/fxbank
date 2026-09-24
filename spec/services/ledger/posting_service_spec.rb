# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ledger::PostingService do
  let(:asset_account) { create(:ledger_account, name: "Clearing USD", code: "1000", account_type: "asset", currency: "USD", cached_balance_subunits: 0) }
  let(:liability_account) { create(:ledger_account, name: "Customer Alice", code: "2000", account_type: "liability", currency: "USD", cached_balance_subunits: 0) }

  describe ".post" do
    context "with balanced entries" do
      it "creates journal, entries, and updates cached balances atomically" do
        journal = described_class.post(
          description: "Customer deposit",
          entries: [
            { account: asset_account, entry_type: "debit", amount_subunits: 10_000 },
            { account: liability_account, entry_type: "credit", amount_subunits: 10_000 }
          ]
        )

        expect(journal).to be_persisted
        expect(journal.status).to eq("posted")
        expect(journal.ledger_entries.count).to eq(2)

        # Asset increases on Debit
        expect(asset_account.reload.cached_balance_subunits).to eq(10_000)
        # Liability increases on Credit
        expect(liability_account.reload.cached_balance_subunits).to eq(10_000)
      end
    end

    context "with unbalanced entries" do
      it "raises UnbalancedJournalError and rolls back completely" do
        expect {
          described_class.post(
            description: "Unbalanced attempt",
            entries: [
              { account: asset_account, entry_type: "debit", amount_subunits: 10_000 },
              { account: liability_account, entry_type: "credit", amount_subunits: 8_000 }
            ]
          )
        }.to raise_error(Ledger::PostingService::UnbalancedJournalError, /Journal unbalanced/)

        expect(LedgerJournal.count).to eq(0)
        expect(LedgerEntry.count).to eq(0)
        expect(asset_account.reload.cached_balance_subunits).to eq(0)
      end
    end

    context "when entry currency does not match account currency" do
      it "raises AccountCurrencyMismatchError and rolls back" do
        expect {
          described_class.post(
            description: "Currency mismatch attempt",
            entries: [
              { account: asset_account, entry_type: "debit", amount_subunits: 10_000, currency: "EUR" },
              { account: liability_account, entry_type: "credit", amount_subunits: 10_000 }
            ]
          )
        }.to raise_error(Ledger::PostingService::AccountCurrencyMismatchError)
      end
    end
  end
end
