# frozen_string_literal: true

require "bigdecimal"

module ValueObjects
  class Money
    include Comparable

    attr_reader :amount_subunits, :currency

    SUPPORTED_CURRENCIES = {
      "USD" => { exponent: 2, symbol: "$" },
      "EUR" => { exponent: 2, symbol: "€" },
      "GBP" => { exponent: 2, symbol: "£" },
      "JPY" => { exponent: 0, symbol: "¥" },
      "CHF" => { exponent: 2, symbol: "CHF " }
    }.freeze

    def self.from_decimal(decimal_amount, currency = "USD")
      currency = currency.to_s.upcase
      exponent = SUPPORTED_CURRENCIES.fetch(currency)[:exponent]
      subunits = (BigDecimal(decimal_amount.to_s) * (10**exponent)).round
      new(subunits, currency)
    end

    def initialize(amount_subunits, currency = "USD")
      @currency = currency.to_s.upcase
      raise ArgumentError, "Unsupported currency: #{@currency}" unless SUPPORTED_CURRENCIES.key?(@currency)

      @amount_subunits = Integer(amount_subunits)
    end

    def decimal_amount
      exponent = SUPPORTED_CURRENCIES[@currency][:exponent]
      BigDecimal(@amount_subunits) / (10**exponent)
    end

    def format
      symbol = SUPPORTED_CURRENCIES[@currency][:symbol]
      exponent = SUPPORTED_CURRENCIES[@currency][:exponent]
      formatted_number = sprintf("%.#{exponent}f", decimal_amount)
      "#{symbol}#{formatted_number}"
    end

    def +(other)
      assert_same_currency!(other)
      Money.new(@amount_subunits + other.amount_subunits, @currency)
    end

    def -(other)
      assert_same_currency!(other)
      Money.new(@amount_subunits - other.amount_subunits, @currency)
    end

    def <=>(other)
      assert_same_currency!(other)
      @amount_subunits <=> other.amount_subunits
    end

    def ==(other)
      other.is_a?(Money) && other.currency == @currency && other.amount_subunits == @amount_subunits
    end

    private

    def assert_same_currency!(other)
      unless other.is_a?(Money) && other.currency == @currency
        raise ArgumentError, "Cannot perform arithmetic between #{@currency} and #{other.try(:currency) || other.class}"
      end
    end
  end
end
