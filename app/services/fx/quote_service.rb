# frozen_string_literal: true

module Fx
  class QuoteService
    QUOTE_VALIDITY = 60.seconds
    DEFAULT_SPREAD = BigDecimal("0.005") # 0.5% margin

    def self.create_quote(user:, from_currency:, to_currency:, source_amount_subunits:)
      new(user, from_currency, to_currency, source_amount_subunits).create_quote
    end

    def initialize(user, from_currency, to_currency, source_amount_subunits)
      @user = user
      @from_currency = from_currency.to_s.upcase
      @to_currency = to_currency.to_s.upcase
      @source_amount_subunits = Integer(source_amount_subunits)
    end

    def create_quote
      market_rate = Fx::RateProvider.rate_for(@from_currency, @to_currency)
      effective_rate = market_rate * (BigDecimal("1.0") - DEFAULT_SPREAD)

      # Convert subunits across currency exponents
      from_exp = ValueObjects::Money::SUPPORTED_CURRENCIES[@from_currency][:exponent]
      to_exp = ValueObjects::Money::SUPPORTED_CURRENCIES[@to_currency][:exponent]

      decimal_source = BigDecimal(@source_amount_subunits) / (10**from_exp)
      decimal_target = decimal_source * effective_rate
      target_subunits = (decimal_target * (10**to_exp)).round

      # Calculate fee capture
      gross_target = (decimal_source * market_rate * (10**to_exp)).round
      fee_subunits = [gross_target - target_subunits, 0].max

      FxQuote.create!(
        user: @user,
        from_currency: @from_currency,
        to_currency: @to_currency,
        source_amount_subunits: @source_amount_subunits,
        target_amount_subunits: target_subunits,
        market_rate: market_rate,
        spread_percent: DEFAULT_SPREAD * 100,
        effective_rate: effective_rate,
        fee_subunits: fee_subunits,
        expires_at: QUOTE_VALIDITY.from_now,
        status: "pending"
      )
    end
  end
end
