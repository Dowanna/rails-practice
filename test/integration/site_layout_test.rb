require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "layout header links" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", signup_path

    # if login successful, header should change
    login_as @user
    assert is_logged_in?
    assert_redirected_to root_path
    follow_redirect!
    assert_select "a[href=?]", users_path
    assert_select "a[href=?]", user_path(current_user)
    assert_select "a[href=?]", edit_user_path(current_user)
    assert_select "a", text: 'Settings'

    # should show stats
    assert_select "section.stats"
  end

  test "layout contact" do
    get contact_path
    assert_select "title", full_title("Contact") 
  end

  test "layout new" do
    get signup_path
    assert_select "title", full_title("Signup")
  end
end
