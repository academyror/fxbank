# frozen_string_literal: true

require "rails_helper"

RSpec.describe LedgerAccount, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:account).optional }
    it { is_expected.to have_many(:ledger_entries).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:ledger_snapshots).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:ledger_account) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_uniqueness_of(:code) }
    it { is_expected.to validate_presence_of(:account_type) }
    it { is_expected.to validate_presence_of(:currency) }
    it { is_expected.to validate_inclusion_of(:currency).in_array(%w[USD EUR GBP JPY CHF]) }
  end

  describe "#computed_balance_subunits" do
    let(:journal) { create(:ledger_journal) }

    context "with asset account (normal debit balance)" do
      let(:asset_account) { create(:ledger_account, account_type: "asset", currency: "USD") }

      it "calculates debits minus credits" do
        create(:ledger_entry, ledger_journal: journal, ledger_account: asset_account, entry_type: "debit", amount_subunits: 10_000, currency: "USD")
        create(:ledger_entry, ledger_journal: journal, ledger_account: asset_account, entry_type: "credit", amount_subunits: 2_500, currency: "USD")

        expect(asset_account.computed_balance_subunits).to eq(7_500)
      end
    end

    context "with liability account (normal credit balance)" do
      let(:liability_account) { create(:ledger_account, account_type: "liability", currency: "USD") }

      it "calculates credits minus debits" do
        create(:ledger_entry, ledger_journal: journal, ledger_account: liability_account, entry_type: "credit", amount_subunits: 20_000, currency: "USD")
        create(:ledger_entry, ledger_journal: journal, ledger_account: liability_account, entry_type: "debit", amount_subunits: 5_000, currency: "USD")

        expect(liability_account.computed_balance_subunits).to eq(15_000)
      end
    end
  end

  describe "#money and #formatted_balance" do
    let(:account) { build(:ledger_account, cached_balance_subunits: 125_50, currency: "USD") }

    it "returns Money value object" do
      expect(account.money).to eq(ValueObjects::Money.new(125_50, "USD"))
    end

    it "formats balance with currency symbol" do
      expect(account.formatted_balance).to eq("$125.50")
    end
  end
end
