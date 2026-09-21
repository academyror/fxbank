# frozen_string_literal: true

class KycVerificationsController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
  end

  def new
    @user = current_user
  end

  def create
    @user = current_user

    if params[:user].present? && (params[:user][:kyc_document].present? || params[:user][:avatar].present?)
      @user.avatar.attach(params[:user][:avatar]) if params[:user][:avatar].present?
      @user.kyc_document.attach(params[:user][:kyc_document]) if params[:user][:kyc_document].present?

      # Dispatch asynchronous verification worker
      KycVerificationJob.perform_later(@user.id)

      redirect_to kyc_verification_path, notice: "Document uploaded successfully. KYC verification is processing."
    else
      flash.now[:alert] = "Please select a valid document or image to upload."
      render :new, status: :unprocessable_entity
    end
  end
end
