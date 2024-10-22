require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  #### create ####

  test 'attempting to create a session with no username should fail' do
    post :create
    assert_equal 'Sign-in failed.', flash['error']
    assert_redirected_to signin_url
  end

  test 'attempting to create a session with an invalid username fails' do
    post :create, params: {
        session: {
            username: 'adsfasdfasfd',
            password: 'password'
        }
    }
    assert_equal 'Sign-in failed.', flash['error']
    assert_redirected_to signin_url
  end

  test 'attempting to create a session for a disabled user fails' do
    users(:disabled).update(last_signin: Time.now)
    post :create, params: {
        session: {
            username: 'disabled',
            password: 'password'
        }
    }
    assert_equal 'Sign-in failed.', flash['error']
    assert_redirected_to signin_url
  end

  test 'attempting to create a session for an unconfirmed user fails' do
    post :create, params: {
        session: {
            username: 'unconfirmed',
            password: 'password'
        }
    }
    assert flash['error'].start_with?('Your account has not yet been confirmed')
    assert_redirected_to signin_url
  end

  test 'attempting to create a session for an enabled, confirmed user with an
  invalid password fails' do
    post :create, params: {
        session: {
            username: 'normal',
            password: 'adfafsafd'
        }
    }
    assert_equal 'Sign-in failed.', flash['error']
    assert_redirected_to signin_url
  end

  test 'attempting to create a session for an enabled, confirmed user succeeds' do
    post :create, params: {
        session: {
            username: 'normal',
            password: 'password'
        }
    }
    assert Time.now - User.find_by_username('normal').last_signin < 0.05
    assert_redirected_to dashboard_url
  end

  #### destroy ####

  test 'destroying a session works when signed in' do
    signin_as(users(:normal))
    delete :destroy
    assert_redirected_to root_url
  end

  test 'destroying a session silently proceeds when not signed in' do
    delete :destroy
    assert_redirected_to root_url
  end

end
