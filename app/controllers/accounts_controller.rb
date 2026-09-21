# frozen_string_literal: true

class AccountsController < ApplicationController
  before_action :authenticate_user!

  def index
    @accounts = policy_scope(Account).order(:account_number)
    @total_balance_cents = @accounts.sum(:balance_cents)
  end

  def show
    @account = Account.find(params[:id])
    authorize @account
    @transfers = @account.transfers.limit(30)
  end
end
