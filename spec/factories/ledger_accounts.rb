# frozen_string_literal: true

FactoryBot.define do
  factory :ledger_account do
    sequence(:name) { |n| "Ledger Account #{n}" }
    sequence(:code) { |n| "ACC-%04d" % n }
    account_type { "asset" }
    currency { "USD" }
    cached_balance_subunits { 0 }
    lock_version { 0 }
  end
end
