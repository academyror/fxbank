# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name phone_number])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[first_name last_name phone_number])
  end

  def after_sign_in_path_for(resource)
    stored_location = stored_location_for(resource)
    return stored_location if stored_location.present?

    accounts_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this financial operation."
    redirect_back(fallback_location: root_path)
  end
end
