require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase
  def setup
    @relationship = Relationship.new(followed_id: users(:michael).id, follower_id: users(:shunya).id)
  end

  test "valid relationship" do
    assert @relationship.valid?
  end

  test "no follower" do
    @relationship.follower = nil
    assert_not @relationship.valid?
  end

  test "no following" do
    @relationship.followed = nil
    assert_not @relationship.valid?
  end
end
