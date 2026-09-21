# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@fxbank.io" }
    password { "Password123!" }
    password_confirmation { "Password123!" }
    first_name { "Jane" }
    last_name { "Doe" }
    phone_number { "+1-555-0199" }
    kyc_status { "verified" }
    role { "customer" }
    confirmed_at { Time.current }

    trait :admin do
      role { "admin" }
    end

    trait :compliance_officer do
      role { "compliance_officer" }
    end

    trait :unconfirmed do
      confirmed_at { nil }
    end

    trait :pending_kyc do
      kyc_status { "pending" }
    end
  end
end
