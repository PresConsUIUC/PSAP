require 'test_helper'

class HelpControllerTest < ActionController::TestCase

  #### index ####

  test 'should get show page' do
    get :index, category: 'help'
    assert_response :success
  end

end
