require 'test_helper'

class UserProfileTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
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
end
