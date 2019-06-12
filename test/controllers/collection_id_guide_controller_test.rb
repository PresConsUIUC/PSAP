require 'test_helper'

class CollectionIdGuideControllerTest < ActionController::TestCase

  #### index ####

  test 'should get index page' do
    get :index
    assert_response :success
  end

  #### show ####

  test 'should get show page' do
    get :show, params: { category: 'avmedia' }
    assert_response :success
  end

end
