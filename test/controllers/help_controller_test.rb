require 'test_helper'

class HelpControllerTest < ActionController::TestCase

  #### index ####

  test 'should get show page' do
    get :index, params: { category: 'help' }
    assert_response :success
  end

end
