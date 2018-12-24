class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]

  def create
    redirect_to login_path unless logged_in?
    @micropost = current_user.microposts.build(micropost_params)

    if @micropost.save
      flash[:success] = 'Successfully posted!'
      redirect_to root_path
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def destroy
    redirect_to login_path unless logged_in?
    micropost = current_user.microposts.find_by(id: params[:id])
    return redirect_to root_path if micropost.nil?

    micropost.destroy
    flash[:success] = 'Micropost deleted'
    redirect_back fallback_location: root_path
  end

  private

  def micropost_params
    params.require(:micropost).permit(:content, :picture)
  end
end
