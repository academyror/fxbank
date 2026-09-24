# Checkpoint C2-02: Immutable Double-Entry Ledgers & Automated Auditing

- **Branch:** [`c2-section/02-double-entry-ledger`](https://github.com/academyror/fxbank/tree/c2-section/02-double-entry-ledger)
- **Tag:** `v2.2-c2-s2`
- **Course:** *Financial SaaS Architecture: Multi-Currency FX, Ledgers & APIs* (Course 2, Section 2) at [rubyonrails.academy](https://www.rubyonrails.academy)

---

## Key Architectural Decisions

1. **The Double-Entry Accounting Paradigm**:
   - Replaced naive balance column mutations (`UPDATE accounts SET balance = ...`) with an append-only, auditor-certified financial ledger.
   - Enforced the fundamental accounting equation: `Assets = Liabilities + Equity`.
   - Customer deposits are properly classified as **Liabilities** (money the bank owes back to depositors on demand).

2. **Relational Topology: Journals, Accounts & Postings**:
   - `LedgerAccount`: Chart of accounts categorized by standard financial classifications (`asset`, `liability`, `equity`, `revenue`, `expense`).
   - `LedgerJournal`: The atomic transaction container linking related entry lines to business events.
   - `LedgerEntry`: Immutable line items representing discrete minor currency subunits (debits and credits).
   - PostgreSQL check constraints: `entry_type IN ('debit', 'credit')` and `amount_subunits > 0`.

3. **Atomic Posting Service & Zero-Sum Invariant**:
   - `Ledger::PostingService`: Enforces that for every currency involved in a journal transaction, the sum of debits strictly equals the sum of credits ($\sum \text{debits} == \sum \text{credits}$). Any unbalanced attempt raises `UnbalancedJournalError` and immediately aborts the transaction.

4. **Denormalized Balance Caching with Optimistic Locking**:
   - Reconciles audit immutability with sub-millisecond dashboard reads by maintaining `cached_balance_subunits` on `LedgerAccount`.
   - Normal balance rules dynamically govern cache updates (Assets/Expenses increase on Debit; Liabilities/Equity/Revenue increase on Credit).
   - Uses `lock_version` for optimistic concurrency protection against race conditions.

5. **Automated Nightly Reconciliation & Drift Audits**:
   - `Ledger::ReconciliationAuditJob`: Background audit worker powered by Solid Queue that verifies:
     - 100% parity between cached balances and the calculated sum of raw historical entries.
     - Zero unbalanced journals across the entire database.
     - Operational alerting on any detected financial drift.

---

## File Highlights in This Checkpoint

- `app/models/ledger_account.rb`
- `app/models/ledger_journal.rb`
- `app/models/ledger_entry.rb`
- `app/models/ledger_snapshot.rb`
- `app/services/ledger/posting_service.rb`
- `app/jobs/ledger/reconciliation_audit_job.rb`
- `db/migrate/20260925000010_create_ledger_tables.rb`
- `db/migrate/20260925000011_create_ledger_snapshots.rb`
- `spec/models/ledger_account_spec.rb`
- `spec/models/ledger_journal_spec.rb`
- `spec/models/ledger_entry_spec.rb`
- `spec/services/ledger/posting_service_spec.rb`
- `spec/jobs/ledger/reconciliation_audit_job_spec.rb`
