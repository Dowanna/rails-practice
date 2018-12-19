require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: 'example_user', email: 'example@example.com',
                      password: 'foobar', password_confirmation: 'foobar')
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "should not allow empty name" do
    @user.name = ' '
    assert_not @user.valid?, assert_not_message(@user)
  end

  test "should not allow empty email" do
    @user.email = nil
    assert_not @user.valid?, assert_not_message(@user)
  end

  test "should not allow name length over 50" do
    @user.name = 'a' * 51
    assert_not @user.valid?, assert_not_message(@user)
  end

  test "should not allow email length over 255" do
    @user.email = 'a' * 255 + '@example.com'
    assert_not @user.valid?, assert_not_message(@user)
  end

  test "should not allow invalid email format" do
    %w[hoge@gmail,com hoge.hoge@...com @@@@@].each do |e|
      @user.email = e
      assert_not @user.valid?, assert_not_message(@user)
    end
  end

  test "should allow valid email format" do
    %w[hoge@gmail.com hoge@hoge.co.jp hoge-inc@hoge-inc.com].each do |e|
      @user.email = e
      assert @user.valid?, assert_message(@user)
    end
  end

  test "should not allow duplicate email" do
    new_user = @user.dup
    new_user.email = @user.email.upcase
    @user.save
    assert_not new_user.valid?
  end

  test "should save email as downcase" do
    EMAIL = 'HOGE@HOGE.com'
    @user.email = EMAIL
    @user.save
    assert_equal EMAIL.downcase, @user.reload.email
  end

  test "should not allow empty password" do
    @user.password = @user.password_confirmation = ' ' * 10
    assert_not @user.valid?, assert_not_message(@user)
  end

  test "should not allow password length under 8" do
    @user.password = @user.password_confirmation = 'a'
    assert_not @user.valid?, assert_not_message(@user)
  end

  test "should not cause error when password_digest is nil" do
    assert_not @user.authenticated?(:password, '')
  end

  private 

  def assert_not_message(user)
    "#{user.inspect} should not be valid"
  end

  def assert_message(user)
    "#{user.inspect} should be valid"
  end
end
