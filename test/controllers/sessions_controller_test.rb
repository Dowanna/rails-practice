require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "the truth" do
    get login_path
    assert_response :success
  end
end
