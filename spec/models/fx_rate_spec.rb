# frozen_string_literal: true

require "rails_helper"

RSpec.describe FxRate, type: :model do
  describe "validations" do
    subject { build(:fx_rate) }

    it { is_expected.to validate_presence_of(:from_currency) }
    it { is_expected.to validate_presence_of(:to_currency) }
    it { is_expected.to validate_presence_of(:rate) }
    it { is_expected.to validate_presence_of(:recorded_at) }
    it { is_expected.to validate_numericality_of(:rate).is_greater_than(0) }
  end
end
