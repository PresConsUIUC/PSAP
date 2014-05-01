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

  test 'adding a query parameter should filter the event list' do
    signin_as(users(:admin_user))

    get :index
    assert_operator assigns(:events).length, :>, 0

    get :index, { q: 'signed in' }
    assert_equal 1, assigns(:events).length

    get :index, { q: 'dsfasdfasdfasdfasfd' }
    assert_equal 0, assigns(:events).length
  end

end
