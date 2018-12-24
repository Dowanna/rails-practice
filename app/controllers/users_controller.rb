class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]

  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    redirect_to root_path unless @user.activated?
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = 'Check your mailer'
      redirect_to root_path
    else 
      flash[:danger] = 'Failed to create new user!'
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = 'Updated user!'
      redirect_to @user
    else
      flash.now[:danger] = 'Failed to update user!'
      render 'edit'
    end
  end

  def destroy
    User.find_by(params[:id]).destroy
    flash[:success] = 'Deleted user'
    redirect_to users_path
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def correct_user
      @user = User.find_by_id(params[:id])
      redirect_to root_path unless current_user?(@user)
    end

    def admin_user
      redirect_to root_path unless current_user.admin?
    end
end
