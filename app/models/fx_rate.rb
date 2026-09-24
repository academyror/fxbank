# frozen_string_literal: true

class FxRate < ApplicationRecord
  validates :from_currency, :to_currency, :rate, :recorded_at, presence: true
  validates :rate, numericality: { greater_than: 0 }
end
