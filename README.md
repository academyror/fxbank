# FxBank &mdash; Section 1: Architecture, Tooling & Environment

Welcome to **FxBank**, a production-grade digital banking SaaS platform built with Ruby on Rails 7.2+, PostgreSQL, Tailwind CSS, and Hotwire.

This repository accompanies **Course 1: Building a Modern SaaS Banking Application** at [Ruby on Rails Academy (rubyonrails.academy)](https://www.rubyonrails.academy).

---

## 📌 Section 1 Overview

In Section 1, we lay the professional foundation for the entire banking platform:
- Deconstructed the digital banking domain (Users, Accounts, immutable Transfer ledgers).
- Initialized the Rails 7.2 architecture configured for PostgreSQL, Tailwind CSS, and esbuild.
- Configured development process orchestration with `Procfile.dev` and `bin/dev`.
- Implemented modern layout scaffolding and system health checking (`/up`).

---

## 🚀 Branch Checkpoints

This repository uses atomic Git branches and tags for each section of the course:

| Branch | Tag | Focus |
|---|---|---|
| `section/01-foundations-architecture` | `v0.1-section-1` | Architecture, Tooling & Environment |
| `section/02-domain-modeling-database` | `v0.2-section-2` | Users, Accounts, Transfers & Pessimistic Locks |
| `section/03-authentication-authorization` | `v0.3-section-3` | Devise Authentication & Pundit Policies |
| `section/04-hotwire-frontend-turbo-stimulus` | `v0.4-section-4` | Reactive Hotwire UI, Turbo Frames & Streams |
| `section/05-cloud-media-background-jobs-email` | `v0.5-section-5` | Active Storage, Solid Queue & Action Mailer |
| `section/06-automated-testing-rspec-tdd` | `v0.6-section-6` | Financial Testing Pyramid (RSpec, FactoryBot) |
| `section/07-deployment-monitoring-day2-ops` | `v0.7-section-7` | Multi-Stage Docker, Kamal 2, Sentry & Lograge |
| `main` | Latest | Complete, Production-Ready Application |

---

## 💻 Getting Started (Section 1)

### 1. Prerequisites
- Ruby 3.2.0 or higher
- PostgreSQL 14+
- Node.js 18+ and Yarn

### 2. Setup
```bash
# Clone the repository
git clone git@github.com:academyror/fxbank.git
cd fxbank

# Checkout Section 1
git checkout section/01-foundations-architecture

# Install dependencies
bundle install
yarn install

# Prepare database
bin/rails db:create

# Start development servers (Rails + Tailwind watch + esbuild watch)
bin/dev
```

Visit `http://localhost:3000` in your browser.

---

## 📚 Full Course & Video Walkthroughs

To access the interactive lessons, quizzes, architectural deep-dives, and community mentorship, visit:  
👉 **[https://www.rubyonrails.academy](https://www.rubyonrails.academy)**
