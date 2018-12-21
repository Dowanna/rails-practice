class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email])
    if @user
      @user.save_reset_digest
      @user.send_password_reset_email
      flash[:info] = 'Check mailer for reset email'
      redirect_to root_path
    else
      flash[:danger] = 'User email not found!'
      redirect_to new_password_reset_path
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, :blank)
      render 'edit'
    elsif @user.update_attributes(user_params)
      log_in(@user)
      flash[:success] = 'Password has been reset!'
      @user.update_attribute(:reset_digest, nil)
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def valid_user
    unless @user && @user.activated? && @user.authenticated?(:reset, params[:id])
      flash[:danger] = 'Not valid user. Activate account, and re-send password reset'
      redirect_to root_path
    end
  end

  def get_user
    @user = User.find_by_email(params[:email])
    redirect_to root_path unless @user
  end

  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = 'Reset expired. Resend email'
      redirect_to new_password_reset_path
    end
  end
end
