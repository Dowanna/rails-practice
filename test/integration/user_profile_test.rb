require 'test_helper'

class UserProfileTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:shunya)
    @microposts = @user.microposts
  end
  
  test "profile shows associated microposts" do
    get user_path(@user)
    assert_select 'span.content', count: [@microposts.count, 30].min
    assert_select 'title', full_title(@user.name)
    assert_select 'h3', "Microposts (#{@microposts.count})"
    assert_select 'div.pagination'
    @user.microposts.paginate(page: 1).each do |m|
      assert_match m.content, response.body
    end
  end

  test "profile shows followed/unfollowed user stat" do
    login_as @user
    follow_redirect!
    assert_select 'div.stats'
    assert_select 'a[href=?] strong#following' , following_user_path(@user), text: '0'
    assert_select 'a[href=?] strong#follower', followers_user_path(@user), text: '0'
  end

  # test "user can follow/unfollow another user" do
  #   login_as @user
  #   get user_path(@other_user)
  #   assert_select 'a[href=?]', follow_user_path(@other_user)

  #   # follow
  #   get follow_user_path(@other_user)
  #   follow_redirect!
  #   assert_template 'users/show'
  #   assert_select 'a[href=?]', unfollow_user_path(@other_user), text: 'unfollow'

  #   # unfollow
  #   get unfollow_user_path(@other_user)
  #   follow_redirect!
  #   assert_template 'users/show'
  #   assert_select 'a[href=?]', follow_user_path(@other_user), text: 'follow'
  # end
end
