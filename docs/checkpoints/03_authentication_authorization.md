# Checkpoint 03: Authentication, Authorization & Roles

- **Branch:** [`section/03-authentication-authorization`](https://github.com/academyror/fxbank/tree/section/03-authentication-authorization)
- **Tag:** `v0.3-section-3`
- **Course Lesson:** Section 3 at [rubyonrails.academy](https://www.rubyonrails.academy)

---

## Key Architectural Decisions

1. **Devise Financial Hardening**:
   - 12 bcrypt stretches in production (~250ms CPU work factor); 1 stretch in test.
   - Zero-grace period email confirmation (`allow_unconfirmed_access_for = 0.days`).
   - Failed attempts account lockout (5 attempts, 1-hour lock).
   - Custom parameter sanitizer in `ApplicationController` for KYC identity fields (`first_name`, `last_name`, `phone_number`).

2. **Declarative Authorization with Pundit**:
   - `AccountPolicy`: Scoped database queries (`policy_scope`) eliminating Insecure Direct Object Reference (IDOR) vulnerabilities.
   - `TransferPolicy`: Restricts transfer execution to verified account owners on active accounts.
   - Dynamic post-login routing (`after_sign_in_path_for`).

---

## File Highlights in This Checkpoint

- `config/initializers/devise.rb`
- `db/migrate/20260901000004_add_devise_and_roles_to_users.rb`
- `app/models/user.rb` (Devise modules & role helpers)
- `app/policies/application_policy.rb`
- `app/policies/account_policy.rb`
- `app/policies/transfer_policy.rb`
- `app/controllers/application_controller.rb`
