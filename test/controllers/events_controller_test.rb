require 'test_helper'

class EventsControllerTest < ActionController::TestCase

  test 'admin users should get the index page' do
    signin_as(users(:admin_user))
    get :index
    assert_response :success
    assert_not_nil assigns :events
  end

  test 'non-admin users cannot view the index page' do
    signin_as(users(:normal_user))
    get :index
    assert_redirected_to root_url
  end

  test 'signed-out users cannot view the index page' do
    get :index
    assert_redirected_to signin_url
  end

end
