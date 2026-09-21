# frozen_string_literal: true

Devise.setup do |config|
  # The secret key used by Devise. If not set, Rails secret_key_base is used.
  config.secret_key = Rails.application.secret_key_base

  # Mailer sender
  config.mailer_sender = 'security@fxbank.io'

  # ==> ORM configuration
  require 'devise/orm/active_record'

  # ==> Configuration for any authentication mechanism
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.skip_session_storage = [:http_auth]

  # 1. Bcrypt Work Factor (Stretches):
  # 12 stretches in production requires ~250ms of CPU per hash, thwarting GPU brute-force cracking.
  # 1 stretch in test environment ensures RSpec test suites run in seconds:
  config.stretches = Rails.env.test? ? 1 : 12

  # 2. Invalidate password reset tokens after 2 hours:
  config.reset_password_within = 2.hours

  # 3. Restrict sign-out to DELETE requests to prevent CSRF logout attacks:
  config.sign_out_via = :delete

  # 4. Lock account after 5 failed password attempts:
  config.lock_strategy = :failed_attempts
  config.maximum_attempts = 5
  config.unlock_strategy = :time
  config.unlock_in = 1.hour

  # 5. Zero tolerance for unconfirmed logins in financial systems:
  config.allow_unconfirmed_access_for = 0.days
  config.confirm_within = 24.hours
  config.reconfirmable = true

  # 6. Security notifications
  config.send_email_changed_notification = true
  config.send_password_change_notification = true
end
