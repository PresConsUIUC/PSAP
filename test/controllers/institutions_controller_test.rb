require 'test_helper'

class InstitutionsControllerTest < ActionController::TestCase

  #### show ####

  test 'signed-out users cannot view any institutions' do
    get :show, id: 3
    assert_response :redirect
  end

  test 'signed-in users can view their own institution' do
    signin_as(users(:normal_user))
    get :show, id: 1
    assert_response :success
    assert_not_nil assigns(:institution)
    assert_not_nil assigns(:resources)
  end

  test 'signed-in users cannot view other institutions' do
    signin_as(users(:normal_user))
    get :show, id: 3
    assert_response :redirect
  end

  test 'admin users can view any institution' do
    signin_as(users(:admin_user))
    get :show, id: 5
    assert_response :success
    assert_not_nil assigns(:institution)
    assert_not_nil assigns(:resources)
  end

  test 'attempting to view a nonexistent institution returns 404' do
    signin_as(users(:normal_user))
    assert_raises(ActiveRecord::RecordNotFound) do
      get :show, id: 999999
      assert_response :missing
    end
  end

end
