# frozen_string_literal: true

require "net/http"
require "json"

module Fx
  class RateProvider
    CACHE_TTL = 60.seconds
    TIMEOUT = 3.seconds

    # Baseline reference rates for emergency fallback / offline dev
    FALLBACK_RATES = {
      "USD" => { "EUR" => 0.92, "GBP" => 0.79, "JPY" => 155.20, "CHF" => 0.90 },
      "EUR" => { "USD" => 1.087, "GBP" => 0.858, "JPY" => 168.70, "CHF" => 0.978 },
      "GBP" => { "USD" => 1.266, "EUR" => 1.165, "JPY" => 196.45, "CHF" => 1.140 },
      "JPY" => { "USD" => 0.0064, "EUR" => 0.0059, "GBP" => 0.0051, "CHF" => 0.0058 },
      "CHF" => { "USD" => 1.111, "EUR" => 1.022, "GBP" => 0.877, "JPY" => 172.44 }
    }.freeze

    def self.rate_for(from_currency, to_currency)
      new.rate_for(from_currency, to_currency)
    end

    def rate_for(from, to)
      from = from.to_s.upcase
      to = to.to_s.upcase

      return BigDecimal("1.0") if from == to

      cache_key = "fx_rate:#{from}:#{to}"

      Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) do
        fetch_live_rate(from, to) || fetch_database_fallback(from, to) || fetch_hardcoded_fallback(from, to)
      end
    end

    private

    def fetch_live_rate(from, to)
      api_key = ENV["FX_RATES_API_KEY"]
      return nil if api_key.blank?

      uri = URI("https://api.exchangerate.host/convert?from=#{from}&to=#{to}&amount=1")
      req = Net::HTTP::Get.new(uri)
      req["Authorization"] = "Bearer #{api_key}"

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = TIMEOUT
      http.read_timeout = TIMEOUT

      response = http.request(req)
      return nil unless response.is_a?(Net::HTTPSuccess)

      data = JSON.parse(response.body)
      rate = data.dig("result") || data.dig("info", "rate")
      BigDecimal(rate.to_s) if rate.present?
    rescue StandardError => e
      Rails.logger.warn("[Fx::RateProvider] External feed timeout or error: #{e.message}")
      nil
    end

    def fetch_database_fallback(from, to)
      record = FxRate.where(from_currency: from, to_currency: to)
                     .order(recorded_at: :desc)
                     .first
      record&.rate
    end

    def fetch_hardcoded_fallback(from, to)
      raw_rate = FALLBACK_RATES.dig(from, to)
      return BigDecimal(raw_rate.to_s) if raw_rate

      # Calculate reciprocal if inverted pair exists
      inverted_rate = FALLBACK_RATES.dig(to, from)
      BigDecimal("1.0") / BigDecimal(inverted_rate.to_s) if inverted_rate
    end
  end
end
