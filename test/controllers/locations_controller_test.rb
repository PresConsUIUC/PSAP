require 'test_helper'

class LocationsControllerTest < ActionController::TestCase

  #### show ####

  test 'signed-out users cannot view any locations' do
    get :show, id: 3
    assert_response :redirect
  end

  test 'signed-in users can view their own locations' do
    signin_as(users(:normal_user))
    get :show, id: 1
    assert_response :success
    assert_not_nil assigns(:location)
    assert_not_nil assigns(:resources)
  end

  test 'signed-in users cannot view other institutions\' locations' do
    signin_as(users(:normal_user))
    get :show, id: 3
    assert_redirected_to root_url
  end

  test 'admin users can view any location' do
    signin_as(users(:admin_user))
    get :show, id: 5
    assert_response :success
    assert_not_nil assigns(:location)
    assert_not_nil assigns(:resources)
  end

  test 'attempting to view a nonexistent location returns 404' do
    signin_as(users(:normal_user))
    assert_raises(ActiveRecord::RecordNotFound) do
      get :show, id: 999999
      assert_response :missing
    end
  end

end
