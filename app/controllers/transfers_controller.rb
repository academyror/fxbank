# frozen_string_literal: true

class TransfersController < ApplicationController
  before_action :authenticate_user!

  def new
    @from_account = policy_scope(Account).find(params[:account_id])
    @transfer = Transfer.new(from_account: @from_account)
    authorize @transfer
  end

  def create
    @from_account = policy_scope(Account).find(params[:transfer][:from_account_id])
    to_account_number = params[:transfer][:to_account_number].to_s.strip.upcase
    to_account = Account.find_by(account_number: to_account_number)

    if to_account.nil?
      flash.now[:alert] = "Destination account '#{to_account_number}' does not exist. Please verify account number."
      @transfer = Transfer.new(from_account: @from_account)
      return render :new, status: :unprocessable_entity
    end

    amount_dollars = params[:transfer][:amount_dollars].to_f
    amount_cents = (amount_dollars * 100).round

    if amount_cents <= 0
      flash.now[:alert] = "Transfer amount must be greater than zero."
      @transfer = Transfer.new(from_account: @from_account)
      return render :new, status: :unprocessable_entity
    end

    @transfer = Transfer.new(
      from_account: @from_account,
      to_account: to_account,
      amount_cents: amount_cents,
      description: params[:transfer][:description],
      idempotency_key: params[:transfer][:idempotency_key].presence || SecureRandom.uuid
    )
    authorize @transfer

    @executed_transfer = Transfers::TransferService.call(
      from_account: @from_account,
      to_account: to_account,
      amount_cents: amount_cents,
      description: @transfer.description,
      idempotency_key: @transfer.idempotency_key
    )

    respond_to do |format|
      format.turbo_stream
      format.html do
        redirect_to account_path(@from_account), notice: "Transfer of #{@executed_transfer.formatted_amount} completed successfully."
      end
    end
  rescue Transfers::TransferError => e
    flash.now[:alert] = e.message
    @transfer = Transfer.new(from_account: @from_account)
    render :new, status: :unprocessable_entity
  end

  def show
    @transfer = Transfer.find(params[:id])
    authorize @transfer
  end
end
