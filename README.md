# FxBank &mdash; Section 3: Authentication, Authorization & Roles

Welcome to **FxBank**, a production-grade digital banking SaaS platform built with Ruby on Rails 7.2+, PostgreSQL, Tailwind CSS, and Hotwire.

This repository accompanies **Course 1: Building a Modern SaaS Banking Application** at [Ruby on Rails Academy (rubyonrails.academy)](https://www.rubyonrails.academy).

---

## 📌 Section 3 Overview

In Section 3, we establish hardened security boundaries around our banking application:
- Integrated **Devise** with high bcrypt stretches (12 in production, 1 in test), 2-hour password reset windows, and failed attempt account locking.
- Configured mandatory email confirmation (`confirmable`) with zero grace period to eliminate anonymous bot abuse.
- Custom parameter sanitization in `ApplicationController` for KYC identity fields (`first_name`, `last_name`, `phone_number`).
- Integrated **Pundit** declarative authorization policies:
  - `AccountPolicy`: strict customer ownership checks and scoped queries (`policy_scope`) to eliminate IDOR (Insecure Direct Object Reference) vulnerabilities.
  - `TransferPolicy`: bilateral checks allowing only verified senders on active accounts to debit funds, and restricting audit receipts to participants and admins.
- Dynamic role-based post-login redirects (`after_sign_in_path_for`).

---

## 🔐 Default Seed Credentials

Run `bin/rails db:seed` to create pre-confirmed demo users:

| User | Email | Password | Role | KYC Status |
|---|---|---|---|---|
| Eleanor (Admin) | `admin@fxbank.io` | `Password123!` | `admin` | Verified |
| Alice Smith | `alice@fxbank.io` | `Password123!` | `customer` | Verified |
| Bob Jones | `bob@fxbank.io` | `Password123!` | `customer` | Verified |
| Charlie Vance | `charlie@fxbank.io` | `Password123!` | `customer` | Pending |

---

## 📚 Full Course & Interactive Curriculum

To access the complete step-by-step video lessons, quizzes, and community mentorship:  
👉 **[https://www.rubyonrails.academy](https://www.rubyonrails.academy)**
