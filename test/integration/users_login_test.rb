require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "login flash does not persist" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: {
      session: {
        email: '',
        password: '1'
      }
    }

    assert_not flash.empty?
    get signup_path
    assert flash.empty?
  end

  test "login / logout status applied to header" do
    get login_path
    post login_path, params: {
      session: {
        email: @user.email,
        password: 'password'
      }
    }
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select 'a[href=?]', login_path, count: 0
    assert_select 'a[href=?]', logout_path
    assert_select 'a[href=?]', user_path(@user)

    delete logout_path
    assert_redirected_to login_path
    follow_redirect!

    # 二つのタブでログアウトを実行した場合
    delete logout_path
    follow_redirect!
    assert_template 'sessions/new'
    assert_select 'a[href=?]', login_path
    assert_select 'a[href=?]', logout_path, count: 0
    assert_select 'a[href=?]', user_path(@user), count: 0
  end

  test "login with remembering" do
    login_as(@user, remember_me: '1')
    assert_equal cookies['remember_token'], assigns(:user).remember_token
  end

  test "login without remembering" do
    login_as(@user, remember_me: '0')
    delete logout_path
    assert_empty cookies['remember_token']
  end
end
