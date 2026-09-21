# frozen_string_literal: true

if ENV['SENTRY_DSN'].present?
  Sentry.init do |config|
    config.dsn = ENV['SENTRY_DSN']
    config.breadcrumbs_logger = %i[active_support_logger http_logger]

    # Set traces_sample_rate to 1.0 to capture 100% of transactions for performance monitoring.
    # In high-volume production, set to 0.1 or 0.2:
    config.traces_sample_rate = Rails.env.production? ? 0.2 : 1.0

    # Sanitize sensitive financial parameters:
    config.send_default_pii = false
    config.environment = Rails.env
  end
end
