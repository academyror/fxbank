# frozen_string_literal: true

require "rails_helper"

RSpec.describe ValueObjects::Money do
  describe ".from_decimal" do
    it "converts decimal amount to minor subunits for 2-decimal currencies" do
      money = described_class.from_decimal(25.50, "USD")
      expect(money.amount_subunits).to eq(2550)
      expect(money.currency).to eq("USD")
    end

    it "converts decimal amount to integer units for 0-decimal currencies (JPY)" do
      money = described_class.from_decimal(5000, "JPY")
      expect(money.amount_subunits).to eq(5000)
      expect(money.currency).to eq("JPY")
    end
  end

  describe "#initialize" do
    it "sets amount_subunits and uppercase currency" do
      money = described_class.new(1000, "eur")
      expect(money.amount_subunits).to eq(1000)
      expect(money.currency).to eq("EUR")
    end

    it "raises ArgumentError for unsupported currencies" do
      expect {
        described_class.new(1000, "XYZ")
      }.to raise_error(ArgumentError, /Unsupported currency: XYZ/)
    end
  end

  describe "#decimal_amount" do
    it "computes BigDecimal value for 2-decimal currency" do
      money = described_class.new(1250, "USD")
      expect(money.decimal_amount).to eq(BigDecimal("12.50"))
    end

    it "computes BigDecimal value for 0-decimal currency (JPY)" do
      money = described_class.new(5000, "JPY")
      expect(money.decimal_amount).to eq(BigDecimal("5000"))
    end
  end

  describe "#format" do
    it "formats USD with symbol and 2 decimals" do
      expect(described_class.new(2550, "USD").format).to eq("$25.50")
    end

    it "formats EUR with symbol and 2 decimals" do
      expect(described_class.new(1000, "EUR").format).to eq("€10.00")
    end

    it "formats GBP with symbol and 2 decimals" do
      expect(described_class.new(750, "GBP").format).to eq("£7.50")
    end

    it "formats JPY with symbol and 0 decimals" do
      expect(described_class.new(5000, "JPY").format).to eq("¥5000")
    end

    it "formats CHF with symbol and 2 decimals" do
      expect(described_class.new(1500, "CHF").format).to eq("CHF 15.00")
    end
  end

  describe "arithmetic and comparison" do
    let(:m1) { described_class.new(1000, "USD") }
    let(:m2) { described_class.new(500, "USD") }
    let(:eur) { described_class.new(500, "EUR") }

    it "adds same currency money objects" do
      result = m1 + m2
      expect(result.amount_subunits).to eq(1500)
      expect(result.currency).to eq("USD")
    end

    it "subtracts same currency money objects" do
      result = m1 - m2
      expect(result.amount_subunits).to eq(500)
      expect(result.currency).to eq("USD")
    end

    it "raises ArgumentError when adding different currencies" do
      expect { m1 + eur }.to raise_error(ArgumentError, /Cannot perform arithmetic between USD and EUR/)
    end

    it "raises ArgumentError when subtracting different currencies" do
      expect { m1 - eur }.to raise_error(ArgumentError, /Cannot perform arithmetic between USD and EUR/)
    end

    it "compares money of same currency" do
      expect(m1).to be > m2
      expect(m2).to be < m1
      expect(m1).to eq(described_class.new(1000, "USD"))
      expect(m1).not_to eq(described_class.new(1000, "EUR"))
    end
  end
end
