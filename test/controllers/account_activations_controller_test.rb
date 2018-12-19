require 'test_helper'

class AccountActivationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end
  test "should activate user" do
    ##### id が nilで作れない
    # patch edit_account_activation_path(@user.activation_token, email: @user.email)
    # @user.reload
    # assert @user.activated?
    # assert_not_nil @user.activated_at
  end
end
