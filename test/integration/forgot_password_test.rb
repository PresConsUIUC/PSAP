require 'test_helper'

class ForgotPasswordTest < ActionDispatch::IntegrationTest

  test 'forgot password page should load' do
    get '/forgot_password'
    assert_response :success
  end

  test 'POSTing to /forgot_password should redirect to /' do
    post_via_redirect('/forgot_password')
    assert_redirected_to '/'
  end

  test 'POSTing to /forgot_password should redirect to / and set the flash' do
    post_via_redirect('/forgot_password',
                      'user' => users(:normal_user).attributes)
    assert_redirected_to '/'

    assert_equal('An email has been sent containing a link to reset your '\
    'password.', flash[:notice])
  end

  test 'POSTing to /forgot_password should send an email' do
    post_via_redirect('/forgot_password',
                      'user' => users(:normal_user).attributes)

    email = UserMailer.password_reset_email(users(:normal_user)).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [Psap::Application.config.psap_email_address], email.from
    assert_equal [users(:normal_user).email], email.to
    assert_equal 'Your request to reset your PSAP password', email.subject
  end

  test 'GETting /new_password without satisfying conditions should redirect to /' do
    get '/new_password'
    assert_redirected_to '/'
  end

  test 'GETting /new_password satisfying conditions should work' do
    user = users(:normal_user)
    user.password_reset_key = 'cats'
    user.save!
    get '/new_password', 'username' => user.username, 'key' => 'cats'
    assert_response :success
  end

  test 'POSTing to /new_password with an invalid username should redirect to /' do
    post_via_redirect('/new_password')
    assert_redirected_to '/'

    post_via_redirect('/new_password', 'user' => { 'username' => 'sfdasdf' })
    assert_redirected_to '/'
  end

  test 'following confirmation link should redirect to /signin and set the flash' do
    post_via_redirect('/new_password', 'user' => users(:normal_user).attributes)
    assert_redirected_to '/signin'
    assert_equal('Password reset successfully.', flash[:success])
  end

end
