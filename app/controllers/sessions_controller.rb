class SessionsController < ApplicationController
  def new
    #debugger
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticated?(:password, params[:session][:password])
      if @user.activated?
        log_in @user
        params[:session][:remember_me] ? remember(@user) : forget(@user)
        redirect_back_or root_path
      else
        flash[:info] = 'Account not activated. Check email for activation link'
        redirect_to root_url
      end
    else
      flash.now[:danger] = 'Invalid login data'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to login_path
  end
end