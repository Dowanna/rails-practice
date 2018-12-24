require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = users(:lana)
    @micropost = @user.microposts.build(content: 'lorem ipsum')
  end

  test "should be valid" do
    assert @micropost.valid?
  end

  test "micropost should not be valid without user" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test "micropost should have content" do
    @micropost.content = nil
    assert_not @micropost.valid?
    @micropost.content = 'a' * 141
    assert_not @micropost.valid?
  end

  test "order should be most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end

  test "destroy micropost when associated user destroyed" do
    @user.microposts.create(content: 'lorem ipsum')
    assert_difference "Micropost.count", -1 do
      @user.destroy
    end
  end
end
