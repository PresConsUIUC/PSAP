require 'test_helper'

class UserFlowsTest < ActionDispatch::IntegrationTest

  def signin
    get '/signin'
    assert_response :success

    post_via_redirect '/sessions',
                      'session[username]' => users(:normal_user).username,
                      'session[password]' => 'password'
    assert_equal '/dashboard', path
  end

  test 'signin with invalid credentials should fail' do
    get '/signin'
    assert_response :success

    post_via_redirect '/sessions',
                      'session[username]' => 'adflakjdfljk',
                      'session[password]' => 'adlkjadlfkjafd'
    assert_equal '/signin', path
  end

  test 'signin should redirect to dashboard' do
    signin
  end

  test 'signout should redirect to landing page' do
    signin
    delete_via_redirect '/signout'
    assert_equal '/', path
  end

end
