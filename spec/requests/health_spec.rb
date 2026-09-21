# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'System Health Check', type: :request do
  describe 'GET /up' do
    it 'returns HTTP 200 OK when application is live and operational' do
      get rails_health_check_path
      expect(response).to have_http_status(:success)
    end
  end
end
