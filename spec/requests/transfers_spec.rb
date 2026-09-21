# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Transfers Endpoints', type: :request do
  let(:sender) { create(:user) }
  let(:recipient) { create(:user) }
  let!(:from_account) { create(:account, user: sender, balance_cents: 20_000) }
  let!(:to_account) { create(:account, user: recipient, balance_cents: 5_000) }

  context 'when authenticated as sender' do
    before do
      sign_in sender
    end

    describe 'GET #new' do
      it 'renders transfer form inside turbo frame' do
        get new_account_transfer_path(from_account), headers: { 'Turbo-Frame' => 'transfer_modal' }
        expect(response).to have_http_status(:success)
        expect(response.body).to include('Send Money')
      end
    end

    describe 'POST #create' do
      context 'with valid transfer attributes' do
        it 'executes the transfer and redirects with success notice' do
          expect {
            post transfers_path, params: {
              transfer: {
                from_account_id: from_account.id,
                to_account_number: to_account.account_number,
                amount_dollars: '50.00',
                description: 'Dinner contribution'
              }
            }
          }.to change(Transfer, :count).by(1)

          expect(response).to redirect_to(account_path(from_account))
          expect(from_account.reload.balance_cents).to eq(15_000)
          expect(to_account.reload.balance_cents).to eq(10_000)
        end
      end

      context 'with insufficient funds' do
        it 'renders unprocessable_entity (422) for Turbo Drive' do
          post transfers_path, params: {
            transfer: {
              from_account_id: from_account.id,
              to_account_number: to_account.account_number,
              amount_dollars: '9999.00'
            }
          }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('Insufficient funds')
        end
      end
    end
  end
end
