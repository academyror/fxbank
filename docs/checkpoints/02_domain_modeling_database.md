# Checkpoint 02: Domain Modeling & Database Craft

- **Branch:** [`section/02-domain-modeling-database`](https://github.com/academyror/fxbank/tree/section/02-domain-modeling-database)
- **Tag:** `v0.2-section-2`
- **Course Lesson:** Section 2 at [rubyonrails.academy](https://www.rubyonrails.academy)

---

## Key Architectural Decisions

1. **Database-Level Invariants**:
   - PostgreSQL check constraints: `balance_cents >= 0` on `accounts` and `amount_cents > 0` on `transfers`.
   - Money stored as integer cents (`bigint`) to eliminate IEEE 754 floating-point rounding errors.

2. **Atomic Money Movement & Concurrency**:
   - `Transfers::TransferService`: Pessimistic row locking (`lock!`) with deterministic ascending ID sorting:
     ```ruby
     accounts_to_lock = [@from_account, @to_account].sort_by(&:id)
     accounts_to_lock.each(&:lock!)
     ```
   - Reload state after lock acquisition to read true committed balances.
   - Idempotency deduplication using unique UUID keys (`idempotency_key`) to prevent double-charging on network retries.

---

## File Highlights in This Checkpoint

- `db/migrate/20260901000001_create_users.rb`
- `db/migrate/20260901000002_create_accounts.rb` (check constraint `balance_cents >= 0`)
- `db/migrate/20260901000003_create_transfers.rb` (check constraint `amount_cents > 0`)
- `app/models/user.rb`, `app/models/account.rb`, `app/models/transfer.rb`
- `app/services/transfers/transfer_service.rb`
- `db/seeds.rb`
