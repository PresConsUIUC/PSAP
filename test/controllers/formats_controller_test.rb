require 'test_helper'

class FormatsControllerTest < ActionController::TestCase

  #### index ####

  test 'signed-out users cannot view the format list' do
    get :index
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot view the format list' do
    signin_as(users(:normal_user))
    get :index
    assert_redirected_to root_url
  end

  test 'admin users can view the format list' do
    signin_as(users(:admin_user))
    get :index
    assert_response :success
    assert_not_nil assigns :formats
  end

  test 'adding a query parameter should filter the format list' do
    signin_as(users(:admin_user))

    get :index
    assert_operator assigns(:formats).length, :>, 3

    get :index, { q: 'post-it' }
    assert_equal 1, assigns(:formats).length

    get :index, { q: 'dsfasdfasdfasdfasfd' }
    assert_equal 0, assigns(:formats).length
  end

  #### show ####

  test 'signed-out users cannot view any formats' do
    get :show, id: 1
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot view any formats' do
    signin_as(users(:normal_user))
    get :show, id: 1
    assert_redirected_to root_url
  end

  test 'admin users can view formats' do
    signin_as(users(:admin_user))
    get :show, id: 1
    assert_response :success
    assert_not_nil assigns :format
  end

  test 'attempting to view a nonexistent format returns 404' do
    signin_as(users(:admin_user))
    assert_raises(ActiveRecord::RecordNotFound) do
      get :show, id: 999999
      assert_response :missing
    end
  end

end
