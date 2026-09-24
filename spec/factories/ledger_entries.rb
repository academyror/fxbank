# frozen_string_literal: true

FactoryBot.define do
  factory :ledger_entry do
    association :ledger_journal
    association :ledger_account
    entry_type { "debit" }
    amount_subunits { 10_000 }
    currency { "USD" }
  end
end
