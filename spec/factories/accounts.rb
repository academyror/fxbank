# frozen_string_literal: true

FactoryBot.define do
  factory :account do
    association :user
    sequence(:account_number) { |n| "FX-%06d" % (100_000 + n) }
    balance_cents { 100_000 } # $1,000.00 default
    currency { "USD" }
    account_type { "checking" }
    status { "active" }

    trait :frozen do
      status { "frozen" }
    end

    trait :closed do
      status { "closed" }
    end

    trait :empty do
      balance_cents { 0 }
    end
  end
end
