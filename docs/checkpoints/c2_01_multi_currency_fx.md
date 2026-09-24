# Checkpoint C2-01: Multi-Currency Architecture & Real-Time FX Conversion Engine

- **Branch:** [`c2-section/01-multi-currency-fx`](https://github.com/academyror/fxbank/tree/c2-section/01-multi-currency-fx)
- **Tag:** `v2.1-c2-s1`
- **Course:** *Financial SaaS Architecture: Multi-Currency FX, Ledgers & APIs* (Course 2, Section 1) at [rubyonrails.academy](https://www.rubyonrails.academy)

---

## Key Architectural Decisions

1. **ISO 4217 Currency Modeling & Integer Subunit Precision**:
   - Eliminated single-currency USD assumptions: accounts isolated by ISO 4217 currency (`USD`, `EUR`, `GBP`, `JPY`, `CHF`).
   - Integer subunit precision prevents floating-point rounding drift. Zero-decimal currencies like `JPY` are handled with discrete 1-to-1 units, while standard currencies use minor subunits (cents/pence).
   - `ValueObjects::Money`: Immutable value object enforcing currency invariants across arithmetic operations (`+`, `-`, `<=>`).

2. **Multi-Tier FX Rate Ingestion & Resilient Caching**:
   - `Fx::RateProvider`: Multi-tier rate resolution with 60-second in-memory caching (`Rails.cache`), external API client with strict 3-second timeouts, historical PostgreSQL fallback table (`fx_rates`), and emergency offline fallbacks.
   - `Fx::SyncRatesJob`: Solid Queue scheduled worker continuously pre-warming exchange rate pairs and logging historical market movements.

3. **Guaranteed Exchange Quotes & 60-Second TTL Reservation Locks**:
   - `FxQuote`: Short-lived financial contracts (60s TTL) eliminating price slippage and customer checkout volatility while protecting the bank from latency arbitrage.
   - `Fx::QuoteService`: Calculates effective rates with configurable platform spread margins (default 0.5%), precision scaling across currency exponents, and automated fee capture.

4. **Atomic Cross-Currency Swap Engine**:
   - `Transfers::FxExchangeService`: Atomic database transaction orchestrating:
     - Quote validity verification (`active?` guard).
     - Account currency invariant verification against quote contract.
     - Deterministic ascending ID sorting for pessimistic row locks (`Account.lock("FOR UPDATE")`) to eliminate PostgreSQL deadlocks under concurrent load.
     - Simultaneous source debit and target credit execution.
     - Quote status transition to `executed` preventing replay attacks.
     - Transfer audit record creation with JSONB metadata tracking rates, spreads, and fee capture.

---

## File Highlights in This Checkpoint

- `app/models/value_objects/money.rb`
- `app/models/fx_quote.rb`
- `app/models/fx_rate.rb`
- `app/models/account.rb` (multi-currency validations & `money` helper)
- `app/models/transfer.rb` (fx_quote association & metadata)
- `app/services/fx/rate_provider.rb`
- `app/services/fx/quote_service.rb`
- `app/services/transfers/fx_exchange_service.rb`
- `app/jobs/fx/sync_rates_job.rb`
- `db/migrate/20260925000001_enhance_accounts_for_multi_currency.rb`
- `db/migrate/20260925000002_create_fx_quotes.rb`
- `db/migrate/20260925000003_add_metadata_and_fx_quote_to_transfers.rb`
- `db/migrate/20260925000004_create_fx_rates.rb`
- `spec/models/value_objects/money_spec.rb`
- `spec/models/fx_quote_spec.rb`
- `spec/models/fx_rate_spec.rb`
- `spec/services/fx/rate_provider_spec.rb`
- `spec/services/fx/quote_service_spec.rb`
- `spec/services/transfers/fx_exchange_service_spec.rb`
