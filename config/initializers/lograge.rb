# frozen_string_literal: true

Rails.application.configure do
  if Rails.env.production? || ENV['LOGRAGE_ENABLED'] == 'true'
    config.lograge.enabled = true
    config.lograge.formatter = Lograge::Formatters::Json.new

    # Include custom metadata in structured log output:
    config.lograge.custom_payload do |controller|
      {
        host: controller.request.host,
        remote_ip: controller.request.remote_ip,
        request_id: controller.request.request_id,
        user_id: controller.try(:current_user)&.id
      }
    end

    # Clean params from logs:
    config.lograge.custom_options = lambda do |event|
      exceptions = %w[controller action format id]
      {
        params: event.payload[:params].except(*exceptions)
      }
    end
  end
end
