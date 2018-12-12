require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users('michael')
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

  test "login status applied to header" do
    get login_path
    post login_path, params: {
      session: {
        email: @user.email,
        password: 'password'
      }
    }
    assert_redirected_to @user
    assert_select 'li', text: 'Log in', count: 0
    assert_select 'li', text: 'Profile'
    assert_select 'li', text: 'Settings'
  end
end
