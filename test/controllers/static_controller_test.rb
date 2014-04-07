require 'test_helper'

class StaticControllerTest < ActionController::TestCase

  test 'should get about page' do
    get :about
    assert_response :success
  end

  test 'should get bibliography page' do
    get :bibliography
    assert_response :success
  end

  test 'should get help page' do
    get :help
    assert_response :success
  end

  test 'should get landing page' do
    get :landing
    assert_response :success
  end

end
