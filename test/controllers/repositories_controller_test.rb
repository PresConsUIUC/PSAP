require 'test_helper'

class RepositoriesControllerTest < ActionController::TestCase

  #### show ####

  test 'signed-out users cannot view any repositories' do
    get :show, id: 3
    assert_redirected_to signin_url
  end

  test 'signed-in users can view their own repositories' do
    signin_as(users(:normal_user))
    get :show, id: 1
    assert_response :success
    assert_not_nil assigns(:repository)
  end

  test 'signed-in users cannot view other institutions\' repositories' do
    signin_as(users(:normal_user))
    get :show, id: 3
    assert_redirected_to root_url
  end

  test 'admin users can view any repository' do
    signin_as(users(:admin_user))
    get :show, id: 5
    assert_response :success
    assert_not_nil assigns(:repository)
  end

  test 'attempting to view a nonexistent repository returns 404' do
    signin_as(users(:normal_user))
    assert_raises(ActiveRecord::RecordNotFound) do
      get :show, id: 999999
      assert_response :missing
    end
  end

end
