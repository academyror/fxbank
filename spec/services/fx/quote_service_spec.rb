# frozen_string_literal: true

require "rails_helper"

RSpec.describe Fx::QuoteService do
  let(:user) { create(:user) }

  describe ".create_quote" do
    it "creates a pending FxQuote with spread, fees, and 60-second expiration" do
      quote = described_class.create_quote(
        user: user,
        from_currency: "USD",
        to_currency: "EUR",
        source_amount_subunits: 10_000 # $100.00
      )

      expect(quote).to be_persisted
      expect(quote.user).to eq(user)
      expect(quote.from_currency).to eq("USD")
      expect(quote.to_currency).to eq("EUR")
      expect(quote.source_amount_subunits).to eq(10_000)
      expect(quote.status).to eq("pending")
      expect(quote.expires_at).to be > Time.current
      expect(quote.expires_at).to be <= 60.seconds.from_now
      expect(quote.effective_rate).to be < quote.market_rate
      expect(quote.target_amount_subunits).to be > 0
    end

    it "correctly calculates subunit conversions for JPY (0-exponent)" do
      quote = described_class.create_quote(
        user: user,
        from_currency: "USD",
        to_currency: "JPY",
        source_amount_subunits: 10_000 # $100.00
      )

      expect(quote.target_amount_subunits).to be > 15_000 # ~¥15,442
      expect(quote.target_money.currency).to eq("JPY")
    end
  end
end
