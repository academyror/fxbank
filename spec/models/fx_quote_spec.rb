# frozen_string_literal: true

require "rails_helper"

RSpec.describe FxQuote, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:transfers).dependent(:nullify) }
  end

  describe "validations" do
    subject { build(:fx_quote) }

    it { is_expected.to validate_presence_of(:from_currency) }
    it { is_expected.to validate_presence_of(:to_currency) }
    it { is_expected.to validate_numericality_of(:source_amount_subunits).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:target_amount_subunits).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:market_rate).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:effective_rate).is_greater_than(0) }
    it { is_expected.to validate_presence_of(:expires_at) }
  end

  describe "scopes and temporal methods" do
    let(:user) { create(:user) }
    let!(:active_quote) { create(:fx_quote, user: user, expires_at: 45.seconds.from_now, status: "pending") }
    let!(:expired_quote) { create(:fx_quote, :expired, user: user, status: "pending") }
    let!(:executed_quote) { create(:fx_quote, :executed, user: user, expires_at: 45.seconds.from_now) }

    it "filters active quotes" do
      expect(described_class.active).to contain_exactly(active_quote)
    end

    it "filters expired unsettled quotes" do
      expect(described_class.expired_unsettled).to contain_exactly(expired_quote)
    end

    describe "#active? and #expired?" do
      it "returns true for active quotes" do
        expect(active_quote.active?).to be true
        expect(active_quote.expired?).to be false
      end

      it "returns false for expired quotes" do
        expect(expired_quote.active?).to be false
        expect(expired_quote.expired?).to be true
      end

      it "returns false for executed quotes" do
        expect(executed_quote.active?).to be false
      end
    end

    describe "#seconds_remaining" do
      it "returns positive integer for active quote" do
        expect(active_quote.seconds_remaining).to be_between(40, 50)
      end

      it "returns 0 for expired quote" do
        expect(expired_quote.seconds_remaining).to eq(0)
      end
    end

    describe "#source_money and #target_money" do
      it "returns Money value objects for source and target amounts" do
        expect(active_quote.source_money).to eq(ValueObjects::Money.new(10_000, "USD"))
        expect(active_quote.target_money).to eq(ValueObjects::Money.new(9_150, "EUR"))
      end
    end
  end
end
