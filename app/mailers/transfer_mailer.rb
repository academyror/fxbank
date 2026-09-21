# frozen_string_literal: true

class TransferMailer < ApplicationMailer
  default from: 'FxBank Notifications <notifications@fxbank.io>'

  def transfer_sent(transfer)
    @transfer = transfer
    @user = transfer.from_account.user

    mail(
      to: @user.email,
      subject: "[FxBank] Confirmation: Transfer of #{@transfer.formatted_amount} Sent"
    )
  end

  def transfer_received(transfer)
    @transfer = transfer
    @user = transfer.to_account.user

    mail(
      to: @user.email,
      subject: "[FxBank] Credit Notice: You received #{@transfer.formatted_amount}"
    )
  end
end
