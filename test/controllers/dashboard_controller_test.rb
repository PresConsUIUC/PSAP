require 'test_helper'

class DashboardControllerTest < ActionController::TestCase

  #### index ####

  test 'signed-out users are redirected to sign-in url' do
    get :index
    assert_redirected_to signin_url
  end

  test 'signed-in users can view the dashboard' do
    signin_as(users(:normal_user))
    get :index
    assert_response :success
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:resources)
  end

  test 'affiliated users have necessary ivars set' do
    signin_as(users(:normal_user))
    get :index
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:resources)
    assert_not_nil assigns(:institution_users)
    assert_not_nil assigns(:recent_assessments)
  end

  test 'unaffiliated users\' necessary ivars are nil' do
    signin_as(users(:unaffiliated_user))
    get :index
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:resources)
    assert_nil assigns(:institution_users)
    assert_nil assigns(:recent_assessments)
  end

end
