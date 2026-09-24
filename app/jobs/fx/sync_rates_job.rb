# frozen_string_literal: true

module Fx
  class SyncRatesJob < ApplicationJob
    queue_as :low_priority

    def perform
      pairs = [
        %w[USD EUR], %w[USD GBP], %w[USD JPY], %w[USD CHF],
        %w[EUR USD], %w[EUR GBP], %w[EUR JPY], %w[EUR CHF],
        %w[GBP USD], %w[GBP EUR], %w[GBP JPY], %w[GBP CHF]
      ]

      pairs.each do |from, to|
        rate = Fx::RateProvider.rate_for(from, to)
        FxRate.create!(from_currency: from, to_currency: to, rate: rate, recorded_at: Time.current)
      end
    end
  end
end
