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
  end

  test 'affiliated users have necessary ivars set' do
    signin_as(users(:normal_user))
    get :index
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:institution_users)
    assert_not_nil assigns(:recent_updated_resources)
  end

  test 'unaffiliated users have necessary ivars are set' do
    signin_as(users(:unaffiliated_user))
    get :index
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:institutions)
  end

end
