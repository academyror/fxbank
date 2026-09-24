# frozen_string_literal: true

FactoryBot.define do
  factory :fx_quote do
    association :user
    from_currency { "USD" }
    to_currency { "EUR" }
    source_amount_subunits { 10_000 } # $100.00
    target_amount_subunits { 9_150 }  # €91.50
    market_rate { BigDecimal("0.920000") }
    spread_percent { BigDecimal("0.50") }
    effective_rate { BigDecimal("0.915400") }
    fee_subunits { 46 }
    expires_at { 60.seconds.from_now }
    status { "pending" }

    trait :expired do
      expires_at { 10.seconds.ago }
    end

    trait :executed do
      status { "executed" }
    end
  end
end
