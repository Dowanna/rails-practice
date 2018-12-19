require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "reject invalid signupt" do
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

  test "should add user" do
    get signup_path
    assert_difference "User.count", 1 do
      post signup_path, params: {
        user: {
          name: 'hoge',
          email: 'hoge@gmail.com',
          password: 'hogehoge',
          password_confirmation: 'hogehoge'
        }
      }
    end
    follow_redirect! #postした結果にリダイレクト
    assert_template 'users/show'
    assert_not flash[:success].nil?, 'flash should not be nil'
  end
end
