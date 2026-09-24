# frozen_string_literal: true

FactoryBot.define do
  factory :ledger_snapshot do
    association :ledger_account
    balance_subunits { 50_000 }
    currency { "USD" }
    snapshot_at { Time.current }
  end
end
