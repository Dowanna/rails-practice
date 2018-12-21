require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "reject invalid signup" do
    get signup_path
    assert_no_difference "User.count" do
      post signup_path, params: {
        user: {
          name: ' ',
          email: 'hoge@gmailcom',
          password: '1',
          password_confirmation: '2'
        }
      }
    end
    assert_template 'users/new'
    # エラーメッセージが正しい数だけ表示されていること
    assert_select 'ul' do |e|
      e.each do |e|
        assert_select e, "li", 3
      end
    end
    assert_select 'form[action=?]', '/users'
  end

  test "valid signup with account activation" do
    assert_difference "User.count", 1 do
      post users_path, params: {
        user: {
          name: 'hoge',
          email: 'hoge@example.com',
          password: 'hogehoge',
          password_confirmation: 'hogehoge'
        }
      }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?

    # 有効かしていない状態でログイン
    login_as(user)
    assert_not is_logged_in?

    # リダイレクトされることも確認
    post login_path(user), params: {
        session: {
          email: 'hoge@example.com',
          password: 'hogehoge'
        }
    }
    assert_redirected_to root_url

    # トークン不正
    get edit_account_activation_url('invalid token', email: user.email)
    assert_not is_logged_in?

    # トークンは正しいがアドレス不正
    get edit_account_activation_url(user.activation_token, email: 'wrong')
    assert_not is_logged_in?

    # 有効なトークン
    get edit_account_activation_url(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
