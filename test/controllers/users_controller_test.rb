require 'test_helper'
include SessionsHelper

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:shunya)
    @unactivated_user = users(:lana)
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "should redirect edit when logged out" do
    get edit_user_path @user
    assert_redirected_to login_path

    # should be redirected to edit after login
    login_as @user
    assert_redirected_to edit_user_path @user

    # should not be redirected upon next login
    log_out
    login_as @user
    assert_redirected_to @user
  end

  test "should redirect update when logged out" do
    patch user_path(@user), params: {
      user: {
        name: @user.name,
        email: @user.email,
        password: '',
        password_confirmation: ''
      }
    }
    assert_redirected_to login_path
  end

  test "should redirect when editing someone else" do
    login_as @other_user
    get edit_user_path @user
    assert_redirected_to root_path
  end

  test "should redirect logged out user upon index" do
    get users_path
    assert_redirected_to login_path
  end

  test "should display all users upon index" do
    login_as @user
    get users_path
    assert_select 'ul.users li', count: [User.where(activated: true).paginate(page: 1).count, 30].min
  end

  test "should redirect to root if user is not activated" do
    login_as @user
    get user_path(@unactivated_user)
    assert_redirected_to root_path
  end

  test "should not be able to update admin flag" do
    login_as @other_user
    assert_not @other_user.admin?
    patch user_path @other_user, params: {
      user: {
        admin: true
      }
    }
    @other_user.reload
    assert_not @other_user.admin?
  end

  test "should not be able to destroy when logged out" do
    assert_no_difference 'User.count' do
      delete user_path @other_user
    end
    assert_redirected_to login_path
  end

  test "should not be able to destroy if not admin" do
    login_as @other_user
    assert_not @other_user.admin?

    assert_no_difference 'User.count' do
      delete user_path @user
    end
    assert_redirected_to root_path
  end

  test "should destroy if admin logged in" do
    login_as @user
    assert @user.admin?

    assert_difference 'User.count', -1 do
      delete user_path @user
    end
    assert_redirected_to users_path
  end
end
