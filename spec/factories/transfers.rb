# frozen_string_literal: true

FactoryBot.define do
  factory :transfer do
    association :from_account, factory: :account
    association :to_account, factory: :account
    amount_cents { 10_000 } # $100.00
    status { "completed" }
    sequence(:idempotency_key) { |n| "tx-idempotency-key-#{n}-#{SecureRandom.hex(4)}" }
    description { "Peer-to-peer funds transfer" }

    trait :failed do
      status { "failed" }
    end
  end
end
