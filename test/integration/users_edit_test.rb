require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "should show error when edit fail" do
    login_as @user
    get edit_user_path @user.id
    patch user_path, params: {
      user: {
        name: '',
        email: '',
        password: '',
        password_confirmation: 'p'
      }
    }
    assert_template 'users/edit'
    assert_select 'div#error_explanation div.alert', text: 'This form contains 3 errors'
  end

  test "should success edit" do
    login_as @user
    get edit_user_path @user.id
    patch user_path, params: {
      user: {
        name: 'newName',
        email: 'new_email@example.com',
        password: '',
        password_confirmation: ''
      }
    }
    assert_redirected_to @user
    follow_redirect!
    assert_not flash[:success].empty?

    # db updated correctly
    @user.reload
    assert_equal @user.name, 'newName'
    assert_equal @user.email, 'new_email@example.com'
  end
end
