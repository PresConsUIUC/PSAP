require 'test_helper'

class EventsControllerTest < ActionController::TestCase

  test 'admin users should get index page' do
    get :index
    # assert_response :success
    # assert_not_nil assigns :events
    flunk 'not written yet'
  end

  test 'non-admin users should not get index page' do
    flunk 'not written yet'
  end

  test 'signed-out users should not get index page' do
    flunk 'not written yet'
  end

end
