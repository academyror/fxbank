# frozen_string_literal: true

require "rails_helper"

RSpec.describe LedgerJournal, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:ledger_entries).dependent(:restrict_with_error) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:posted_at) }
  end

  describe "#balanced?" do
    let(:journal) { create(:ledger_journal) }
    let(:acc1) { create(:ledger_account, currency: "USD", account_type: "asset") }
    let(:acc2) { create(:ledger_account, currency: "USD", account_type: "liability") }

    it "returns true when debits equal credits for each currency" do
      create(:ledger_entry, ledger_journal: journal, ledger_account: acc1, entry_type: "debit", amount_subunits: 10_000, currency: "USD")
      create(:ledger_entry, ledger_journal: journal, ledger_account: acc2, entry_type: "credit", amount_subunits: 10_000, currency: "USD")

      expect(journal.balanced?).to be true
    end

    it "returns false when debits and credits do not match" do
      create(:ledger_entry, ledger_journal: journal, ledger_account: acc1, entry_type: "debit", amount_subunits: 10_000, currency: "USD")
      create(:ledger_entry, ledger_journal: journal, ledger_account: acc2, entry_type: "credit", amount_subunits: 5_000, currency: "USD")

      expect(journal.balanced?).to be false
    end

    it "returns false when journal has no entries" do
      expect(journal.balanced?).to be false
    end
  end
end
