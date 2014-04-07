require 'test_helper'

class UserFlowsTest < ActionDispatch::IntegrationTest

  test 'landing page should redirect signed-in users to dashboard' do
    #login_as User.new(username: 'normal')
    #get :landing
    #assert_equal '/dashboard', path
  end

  test 'signin' do
    get '/signin'
    assert_response :success

    post_via_redirect '/sessions',
                      'session[username]' => users(:normal_user).username,
                      'session[password]' => 'password'
    assert_equal '/dashboard', path
  end

end
