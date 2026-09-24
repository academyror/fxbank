# frozen_string_literal: true

require "rails_helper"

RSpec.describe LedgerEntry, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:ledger_journal) }
    it { is_expected.to belong_to(:ledger_account) }
  end

  describe "validations" do
    subject { build(:ledger_entry) }

    it { is_expected.to validate_presence_of(:entry_type) }
    it { is_expected.to validate_presence_of(:amount_subunits) }
    it { is_expected.to validate_numericality_of(:amount_subunits).is_greater_than(0) }
    it { is_expected.to validate_presence_of(:currency) }
    it { is_expected.to validate_inclusion_of(:currency).in_array(%w[USD EUR GBP JPY CHF]) }
  end

  describe "#money" do
    let(:entry) { build(:ledger_entry, amount_subunits: 75_00, currency: "EUR") }

    it "returns Money value object" do
      expect(entry.money).to eq(ValueObjects::Money.new(75_00, "EUR"))
    end
  end
end
