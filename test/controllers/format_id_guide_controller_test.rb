require 'test_helper'

class FormatIdGuideControllerTest < ActionController::TestCase

  #### index ####

  test 'should get index page' do
    get :index
    assert_response :success
  end

end
