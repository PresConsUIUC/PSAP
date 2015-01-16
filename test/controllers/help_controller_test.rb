require 'test_helper'

class HelpControllerTest < ActionController::TestCase

  #### show ####

  test 'should get show page' do
    get :show, category: 'help'
    assert_response :success
  end

end
