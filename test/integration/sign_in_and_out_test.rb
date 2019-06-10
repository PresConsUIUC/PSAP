require 'test_helper'

class SignInAndOutTest < ActionDispatch::IntegrationTest

  setup do
    @valid_username = users(:normal_user).username
    @valid_password = 'password'
  end

  test 'signin with invalid credentials should fail' do
    signin('adfasdf', 'asdfasfafd')
    assert_equal '/signin', path
    assert_equal('Sign-in failed.', flash['error'])
  end

  test 'signin should redirect to dashboard' do
    get '/signin'
    assert_response 302
    signin(@valid_username, @valid_password)
    assert_equal('/dashboard', path)
  end

  test 'signout should redirect to landing page' do
    signin(@valid_username, @valid_password)
    delete_via_redirect '/signout'
    assert_equal('/', path)
  end

end
