# frozen_string_literal: true

FactoryBot.define do
  factory :fx_rate do
    from_currency { "USD" }
    to_currency { "EUR" }
    rate { BigDecimal("0.920000") }
    recorded_at { Time.current }
  end
end
