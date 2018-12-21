require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test "should reset password" do
    get new_password_reset_path
    assert_template 'password_resets/new'

    #不正なアドレスを入力
    post password_resets_path, params: {
      password_reset: {
        email: ''
      }
    }
    assert_equal flash[:danger], 'User email not found!'
    assert_redirected_to new_password_reset_path

    #正しいアドレスを入力
    post password_resets_path, params: {
      password_reset: {
        email: @user.email
      }
    }
    assert_equal flash[:info], 'Check mailer for reset email'
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_redirected_to root_path

    user = assigns(:user)

    #メールアドレス無効（メールリンクに正しくパラメータ設定されていない）
    get edit_password_reset_path(user.reset_token, email: '')
    assert_redirected_to root_path

    #誤ったトークンでパスワード再設定画面に遷移するとルートに転送される
    get edit_password_reset_path('wrong_token', email: user.email)
    assert_redirected_to root_path

    #メールもトークンも適切だが、ユーザが未有効だとルートに転送される
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_equal flash[:danger], 'Not valid user. Activate account, and re-send password reset'
    assert_redirected_to root_path
    user.toggle!(:activated)

    #メールもトークンも有効
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email #updateでユーザ取得する用のメルアドをhiddenに入れる

    #新規パスワードが無効
    patch password_reset_path(user.reset_token), params: {
      email: user.email,
      user: {
        password: '',
        password_confirmation: ''
      }
    }
    assert_template 'password_resets/edit'
    assert_select "div#error_explanation"

    #パスワード変更期限切れ
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'

    user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(user.reset_token), params: {
      email: user.email,
      user: {
        password: 'resetpassword',
        password_confirmation: 'resetpassword'
      }
    }
    assert_response :redirect
    assert_redirected_to new_password_reset_path
    follow_redirect!
    assert_match 'expire', response.body
    user.update_attribute(:reset_sent_at, Time.zone.now)

    #有効なパスワード再設定
    patch password_reset_path(user.reset_token), params: {
      email: user.email,
      user: {
        password: 'resetpassword',
        password_confirmation: 'resetpassword'
      }
    }
    user.reload
    assert_not user.authenticate('password')
    assert user.authenticate('resetpassword')
    assert is_logged_in?
    assert_redirected_to user

    #パスワード再設定したらreset_digestがリセットされる事を確認
    assert_nil user.reset_digest
  end
end
