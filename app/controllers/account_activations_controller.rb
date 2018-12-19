class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by_email(params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = 'Activation complete!'
      redirect_back_or user
    else
      flash[:danger] = 'Invalid activation'
      redirect_to root_url
    end
  end
end
