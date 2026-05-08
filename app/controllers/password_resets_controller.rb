# frozen_string_literal: true

class PasswordResetsController < ApplicationController
  respond_to :html, :xml, :json

  verify_captcha only: :create

  rescue_from ActiveSupport::MessageVerifier::InvalidSignature do
    redirect_to password_reset_path, notice: "Password reset link is invalid or expired. Request a new one.", status: 303
  end

  rescue_from Pundit::NotAuthorizedError do
    redirect_to profile_path, notice: "Already logged in"
  end

  # Show the password reset request page.
  def show
    authorize CurrentUser.user, policy_class: PasswordResetPolicy
  end

  # Show the change password form.
  def edit
    @user = authorize User.find_signed!(params.dig(:user, :signed_id), purpose: :password_reset), policy_class: PasswordResetPolicy
  end

  # Send the password reset request.
  def create
    name = params.dig(:user, :name)
    @user = authorize User.find_by_name(name), policy_class: PasswordResetPolicy

    @user&.request_password_reset!(request)

    flash[:notice] = "Password reset link has been generated"

    redirect_to password_reset_path
  end

  # Change the user's password.
  def update
    @user = authorize User.find_signed!(params.dig(:user, :signed_id), purpose: :password_reset), policy_class: PasswordResetPolicy

    success = @user.reset_password(
      new_password: params.dig(:user, :password),
      password_confirmation: params.dig(:user, :password_confirmation),
      verification_code: params.dig(:user, :verification_code),
      request: request,
    )

    if success
      SessionLoader.new(request).login_user(@user, :login)
      notice = "Password updated"
    end

    respond_with(@user, notice: notice)
  end
end
