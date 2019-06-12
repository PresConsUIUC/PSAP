require 'test_helper'

class PasswordControllerTest < ActionController::TestCase

  #### forgot-password ####

  test 'forgot-password page should display' do
    get :forgot_password
    assert_response :success
  end

  #### send_email ####

  test 'send_email should redirect to root url if no user provided' do
    post :send_email
    assert_redirected_to root_url
  end

  test 'send_email should redirect to root url if invalid user provided' do
    post :send_email, params: { post: { username: 'asdflkjsafdljk' } }
    assert_redirected_to root_url
  end

  test 'send_email should work' do
    user = users(:normal_user)
    key1 = user.password_reset_key

    post :send_email, params: { email: users(:normal_user).email }

    user.reload
    assert_not_equal key1, user.password_reset_key
    assert_equal 'An email has been sent containing a link to reset your password.',
                 flash['notice']
    assert_redirected_to root_url
  end

  #### new_password ####

  test 'new-password page should redirect to root url if no user provided' do
    get :new_password
    assert_redirected_to root_url
  end

  test 'new-password page should redirect to root url if invalid user provided' do
    get :new_password, params: { username: 'adflajsflaskjfaslf' }
    assert_redirected_to root_url
  end

  test 'new-password page should redirect to root url if user doesn\'t have a password reset key' do
    get :new_password, params: { username: 'normal', key: 'cats' }
    assert_redirected_to root_url
  end

  test 'new-password page should redirect to root url if invalid password reset key provided' do
    users(:normal_user).password_reset_key = 'cats'
    users(:normal_user).save!
    get :new_password, params: { username: 'normal', key: 'adlfkjasdflkjasdf' }
    assert_redirected_to root_url
  end

  test 'new-password page should redirect to root url if password reset key not provided' do
    users(:normal_user).password_reset_key = 'cats'
    users(:normal_user).save!
    get :new_password, params: { username: 'normal' }
    assert_redirected_to root_url
  end

  test 'new-password page should display if valid user and key provided' do
    users(:normal_user).password_reset_key = 'cats'
    users(:normal_user).save!
    get :new_password, params: { username: 'normal', key: 'cats' }
    assert_response :success
  end

  #### reset_password

  test 'reset-password page should redirect to root url if no user provided' do
    post :reset_password
    assert_redirected_to root_url
  end

  test 'reset-password page should redirect to root url if invalid user provided' do
    post :reset_password, params: { user: { username: 'dsadfasfd' } }
    assert_redirected_to root_url
  end

  test 'reset-password page should redirect to root url if invalid password reset key provided' do
    users(:normal_user).password_reset_key = 'cats'
    users(:normal_user).save!
    post :reset_password, params: {
        user: {
            username: 'dsfasdffd',
            password_reset_key: 'afdkjsfasdf'
        }
    }
    assert_redirected_to root_url
  end

  test 'reset-password page should redirect to root url if user has no password reset key' do
    post :reset_password, params: {
        user: {
            username: 'dsfasdffd',
            password_reset_key: 'cats'
        }
    }
    assert_redirected_to root_url
  end

  test 'reset_password should do what it\'s supposed to' do
    post :reset_password, params: { user: { username: 'normal' } }

    assert_nil users(:normal_user).password_reset_key
    assert_equal 'Password reset successfully.', flash['success']
    assert_redirected_to signin_url
  end

end
