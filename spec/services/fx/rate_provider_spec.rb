# frozen_string_literal: true

require "rails_helper"

RSpec.describe Fx::RateProvider do
  describe ".rate_for" do
    it "returns 1.0 when from and to currencies are identical" do
      expect(described_class.rate_for("USD", "USD")).to eq(BigDecimal("1.0"))
      expect(described_class.rate_for("eur", "EUR")).to eq(BigDecimal("1.0"))
    end

    it "returns fallback rate for known currency pairs" do
      rate = described_class.rate_for("USD", "EUR")
      expect(rate).to eq(BigDecimal("0.92"))
    end

    it "computes reciprocal rate when inverted pair is defined" do
      rate = described_class.rate_for("CHF", "USD")
      expect(rate).to be_within(BigDecimal("0.01")).of(BigDecimal("1.11"))
    end

    context "when a recorded rate exists in database" do
      before do
        create(:fx_rate, from_currency: "USD", to_currency: "EUR", rate: BigDecimal("0.955"), recorded_at: 5.minutes.ago)
        Rails.cache.clear
      end

      it "uses the database rate if live feed is unavailable" do
        rate = described_class.rate_for("USD", "EUR")
        expect(rate).to eq(BigDecimal("0.955"))
      end
    end
  end
end
