# Checkpoint 01: Foundations, Architecture & Tooling

- **Branch:** [`section/01-foundations-architecture`](https://github.com/academyror/fxbank/tree/section/01-foundations-architecture)
- **Tag:** `v0.1-section-1`
- **Course Lesson:** Section 1 at [rubyonrails.academy](https://www.rubyonrails.academy)

---

## Key Architectural Decisions

1. **Separation of Concerns from First Principles**:
   - Deconstructed why banks cannot store a `balance` column directly on a `User` table (customers hold checking and savings accounts, multi-currency holdings).
   - Structured the three primary entities: `User` (identity), `Account` (financial contract), `Transfer` (immutable double-entry ledger).

2. **Application Tooling**:
   - Initialized Rails 7.2 SaaS architecture with PostgreSQL, Tailwind CSS, and esbuild.
   - Configured `Procfile.dev` and `bin/dev` to orchestrate Rails, Tailwind watch, and esbuild watch processes concurrently.
   - Established `/up` health check routing.

---

## File Highlights in This Checkpoint

- `Procfile.dev` & `bin/dev`
- `package.json` & `tailwind.config.js`
- `app/controllers/home_controller.rb` & `app/views/home/index.html.erb`
- `app/views/layouts/application.html.erb`
- `config/database.yml`
