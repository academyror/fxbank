# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Accounts API/Endpoints', type: :request do
  let(:user) { create(:user) }
  let!(:account) { create(:account, user: user, balance_cents: 50_000) }

  context 'when unauthenticated' do
    it 'redirects GET #index to sign in' do
      get accounts_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context 'when authenticated' do
    before do
      sign_in user
    end

    describe 'GET #index' do
      it 'renders accounts list successfully' do
        get accounts_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include(account.account_number)
      end
    end

    describe 'GET #show' do
      it 'renders account details and statement' do
        get account_path(account)
        expect(response).to have_http_status(:success)
        expect(response.body).to include(account.account_number)
      end

      it 'forbids viewing an account belonging to another user' do
        other_account = create(:account, user: create(:user))
        get account_path(other_account)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include('not authorized')
      end
    end
  end
end
