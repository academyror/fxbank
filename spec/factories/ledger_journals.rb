# frozen_string_literal: true

FactoryBot.define do
  factory :ledger_journal do
    description { "Customer deposit journal" }
    status { "posted" }
    posted_at { Time.current }
  end
end
