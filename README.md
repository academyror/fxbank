# FxBank &mdash; Section 4: Hotwire Frontend (Turbo & Stimulus)

Welcome to **FxBank**, a production-grade digital banking SaaS platform built with Ruby on Rails 7.2+, PostgreSQL, Tailwind CSS, and Hotwire.

This repository accompanies **Course 1: Building a Modern SaaS Banking Application** at [Ruby on Rails Academy (rubyonrails.academy)](https://www.rubyonrails.academy).

---

## 📌 Section 4 Overview

In Section 4, we build an interactive Hotwire banking dashboard without the complexity or weight of heavy client-side JavaScript frameworks:
- **Turbo Drive**: Fast SPA-like navigations, progress indicators, HTTP 303 redirects on success, and HTTP 422 on validation failures.
- **Turbo Frames**:
  - Accounts dashboard with inline modal transfer drawers (`turbo_frame_tag "transfer_modal"`).
  - Scope form validation errors within the modal without full page reload.
- **Turbo Streams**:
  - Real-time reactive updates prepending completed transfers directly into `#transfers_list`.
  - In-place account balance replacement (`account_balance_:id`).
  - Automatic dismissal of the transfer modal.
- **Stimulus Controllers**:
  - `clipboard_controller.js`: Instant account number copying with visual feedback.
  - `currency_input_controller.js`: Live dollar-to-cent formatting and preview.
  - `modal_controller.js`: Clean keyboard (Escape) and backdrop dismiss handlers.

---

## 🎨 User Interface Highlights

- **Accounts Dashboard (`/accounts`)**: Financial overview with net balance aggregation across active accounts.
- **Account Detail & Ledger (`/accounts/:id`)**: Comprehensive chronological transaction statement distinguishing incoming credits (green `+`) from outgoing debits (red `-`).
- **Send Money Flow (`/accounts/:id/transfers/new`)**: Inline modal with live validation and error handling.

---

## 📚 Full Course & Interactive Curriculum

To access the complete step-by-step video lessons, quizzes, and community mentorship:  
👉 **[https://www.rubyonrails.academy](https://www.rubyonrails.academy)**
