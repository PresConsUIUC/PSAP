require 'test_helper'

class StaticControllerTest < ActionController::TestCase

  test 'about page' do
    get :about
    assert_response :success
  end

  test 'bibliography page' do
    get :bibliography
    assert_response :success
  end

  test 'getting started page' do
    get :getting_started
    assert_response :success
  end

  test 'glossary page' do
    get :glossary
    assert_response :success
  end

  test 'landing page' do
    get :landing
    assert_response :success
  end

end
