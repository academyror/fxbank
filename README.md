# FxBank &mdash; Section 6: Automated Testing & Quality Gates (TDD with RSpec)

Welcome to **FxBank**, a production-grade digital banking SaaS platform built with Ruby on Rails 7.2+, PostgreSQL, Tailwind CSS, and Hotwire.

This repository accompanies **Course 1: Building a Modern SaaS Banking Application** at [Ruby on Rails Academy (rubyonrails.academy)](https://www.rubyonrails.academy).

---

## 📌 Section 6 Overview

In Section 6, we construct an automated financial safety net using **RSpec**, **FactoryBot**, and **Shoulda Matchers**:
- **Testing Pyramid Execution**:
  - **70% Unit Specs**: Testing domain invariants, model validations, custom calculation helpers, and isolated Pundit policies.
  - **20% Request Specs**: Testing Devise authentication cookies, HTTP routing contracts, Turbo 303 redirects, and 422 Unprocessable Content handling.
  - **10% Service & Job Specs**: Verifying transaction atomicity, rollback on unexpected SQL failures, and background queue dispatching.
- **Financial Concurrency & Atomic Rollback Guarantees**:
  - `Transfers::TransferService`: Overdraft tests ensuring 0 balance drift under failed transfers.
  - Simulating database exceptions mid-transaction to verify atomic rollback guarantees.
  - Idempotency key deduplication tests ensuring repeated retries do not double-debit funds.

---

## 🧪 Running the Test Suite

```bash
# Run all specs
bundle exec rspec

# Run specific domain service specs
bundle exec rspec spec/services/transfers/transfer_service_spec.rb

# Run authorization policy specs
bundle exec rspec spec/policies/
```

---

## 📚 Full Course & Interactive Curriculum

To access the complete step-by-step video lessons, quizzes, and community mentorship:  
👉 **[https://www.rubyonrails.academy](https://www.rubyonrails.academy)**
