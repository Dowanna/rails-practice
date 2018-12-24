require 'test_helper'

class MicropostsTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:shunya)
  end

  test "should redirect to login if not logged in" do
    post microposts_path, params: {
      micropost: {
        content: 'valid'
      }
    }
    assert_redirected_to login_path
  end

  test "when post fails, should still render" do
    login_as(@user)    
    post microposts_path, params: {
      micropost: {
        content: 'a'*141
      }
    }
    assert_template 'static_pages/home'

    post microposts_path, params: {
      micropost: {
        content: ''
      }
    }
    assert_template 'static_pages/home'
  end

  test "should be able to post" do
    login_as(@user)
    assert_difference 'Micropost.count', 1 do
      post microposts_path(@user), params: {
        micropost: {
          content: 'hi there'
        }
      }
    end
  end

  test "should destroy and render home" do
    login_as(@user)
    get root_path
    assert_template 'static_pages/home'

    content = @user.microposts.first.content
    assert_match content, response.body
    delete micropost_path(@user.microposts.first)

    # 削除後に残っていない事を確認
    assert_redirected_to root_path
    follow_redirect!
    assert_no_match content, response.body
  end

  test "should not be able to destroy someone else's post" do
    login_as(@other_user)
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'a', text: 'delete', count: 0

    content = @user.microposts.first.content
    assert_match content, response.body
    delete micropost_path(@user.microposts.first)

    # 他人のmiropostは削除できないのでリダイレクトされる
    assert_redirected_to root_path
  end

end
