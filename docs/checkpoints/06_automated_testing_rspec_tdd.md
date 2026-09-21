# Checkpoint 06: Automated Testing & Quality Gates (TDD with RSpec)

- **Branch:** [`section/06-automated-testing-rspec-tdd`](https://github.com/academyror/fxbank/tree/section/06-automated-testing-rspec-tdd)
- **Tag:** `v0.6-section-6`
- **Course Lesson:** Section 6 at [rubyonrails.academy](https://www.rubyonrails.academy)

---

## Key Architectural Decisions

1. **The Financial Testing Pyramid**:
   - 70% Unit Specs (Models, Pundit policies, isolated calculation helpers).
   - 20% Request Specs (HTTP routing, authentication cookies, status codes, Turbo responses).
   - 10% Service & Job Specs (Transaction atomicity, rollbacks, background queues).

2. **Atomic Rollback & Concurrency Verification**:
   - `spec/services/transfers/transfer_service_spec.rb`:
     - Proves overdrafts raise `InsufficientFundsError` with 0 balance drift.
     - Simulates unexpected mid-transaction database failures to verify complete rollbacks.
     - Validates idempotency key deduplication on repeated submissions.
   - Pundit policy specs executing in memory in <5ms without database round-trips.

---

## File Highlights in This Checkpoint

- `spec/rails_helper.rb` & `spec/spec_helper.rb`
- `spec/factories/` (`users.rb`, `accounts.rb`, `transfers.rb`)
- `spec/models/` (`user_spec.rb`, `account_spec.rb`, `transfer_spec.rb`)
- `spec/services/transfers/transfer_service_spec.rb`
- `spec/policies/` (`account_policy_spec.rb`, `transfer_policy_spec.rb`)
- `spec/requests/` (`accounts_spec.rb`, `transfers_spec.rb`)
- `spec/mailers/transfer_mailer_spec.rb`
- `spec/jobs/transfer_notification_job_spec.rb`
