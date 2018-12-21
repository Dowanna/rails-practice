require 'test_helper'

class PasswordResetControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "should get new" do
    get new_password_reset_url
    assert_response :success
  end

  test "should redirect to root without reset token" do
    get edit_password_reset_url(@user)
    assert_redirected_to root_path
  end
end
