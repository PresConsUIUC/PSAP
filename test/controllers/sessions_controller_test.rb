require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  #### create ####

  test 'attempting to create a session with no username should fail' do
    assert_difference 'Event.count' do
      post :create
    end
    assert_equal 'Invalid username/password combination.', flash[:error]
    assert_equal 'Sign-in failed', Event.last.description[0..13]
    assert_redirected_to signin_url
  end

  test 'attempting to create a session with an invalid username fails' do
    assert_difference 'Event.count' do
      post :create, session: { username: 'adsfasdfasfd', password: 'password' }
    end
    assert_equal 'Invalid username/password combination.', flash[:error]
    assert_equal 'Sign-in failed', Event.last.description[0..13]
    assert_redirected_to signin_url
  end

  test 'attempting to create a session for a disabled user fails' do
    assert_difference 'Event.count' do
      post :create, session: { username: 'disabled', password: 'password' }
    end
    assert_equal 'Invalid username/password combination.', flash[:error]
    assert_equal 'Sign-in failed', Event.last.description[0..13]
    assert_redirected_to signin_url
  end

  test 'attempting to create a session for an unconfirmed user fails' do
    assert_difference 'Event.count' do
      post :create, session: { username: 'unconfirmed', password: 'password' }
    end
    assert_equal 'Invalid username/password combination.', flash[:error]
    assert_equal 'Sign-in failed', Event.last.description[0..13]
    assert_redirected_to signin_url
  end

  test 'attempting to create a session for an enabled, confirmed user with an invalid password fails' do
    assert_difference 'Event.count' do
      post :create, session: { username: 'normal', password: 'adfafsafd' }
    end
    assert_equal 'Invalid username/password combination.', flash[:error]
    assert_equal 'Sign-in failed', Event.last.description[0..13]
    assert_redirected_to signin_url
  end

  test 'attempting to create a session for an enabled, confirmed user succeeds' do
    assert_difference 'Event.count' do
      post :create, session: { username: 'normal', password: 'password' }
    end
    assert_equal 'User normal signed in', Event.last.description[0..20]
    assert Time.now - User.find_by_username('normal').last_signin < 0.05
    assert_redirected_to dashboard_url
  end

  #### destroy ####

  test 'destroying a session works when signed in' do
    signin_as(users(:normal_user))
    delete :destroy
    assert_equal 'User normal signed out', Event.last.description[0..21]
    assert_redirected_to root_url
  end

  test 'destroying a session silently proceeds when not signed in' do
    delete :destroy
    assert_redirected_to root_url
  end

end
