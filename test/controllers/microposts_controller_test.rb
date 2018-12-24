require 'test_helper'

class MicropostsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @micropost = @user.microposts.first
  end

  test "redirected if create by unlogged in user" do
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: {
        microposts: {
          content: ''
        }
      }
    end
    assert_redirected_to login_path
  end

  test "redirected if destroy by unlogged in user" do
    assert_no_difference 'Micropost.count' do
      delete micropost_path(@micropost)
    end
    assert_redirected_to login_path
  end
end
