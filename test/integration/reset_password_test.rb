require 'test_helper'

class ResetPasswordTest < ActionDispatch::IntegrationTest

  setup do
    @user = users(:normal_user)
  end

  # GET /forgot-password

  test 'forgot password page should load' do
    get '/forgot-password'
    assert_response :success
  end

  # POST /forgot-password

  test 'POSTing nothing to /forgot-password should redirect to /' do
    post_via_redirect('/forgot-password')
    assert_equal '/', path
  end

  test 'POSTing an invalid email to /forgot-password should redirect to /forgot-password' do
    post_via_redirect('/forgot-password', email: 'adlfkjasdjk@example.org')
    assert_equal '/forgot-password', path
  end

  test 'POSTing an invalid email to /forgot-password should set the flash' do
    post_via_redirect('/forgot-password', email: 'asdlfjkljk@example.org')
    assert_equal('No user found with the given email address.', flash['error'])
  end

  test 'POSTing a valid password to /forgot-password should redirect to /' do
    post_via_redirect('/forgot-password', email: @user.email)
    assert_equal '/', path
  end

  test 'POSTing a valid password to /forgot-password should set the flash' do
    post_via_redirect('/forgot-password', email: @user.email)
    assert_equal('An email has been sent containing a link to reset your '\
    'password.', flash[:notice])
  end

  test 'POSTing a valid password to /forgot-password should send an email' do
    post_via_redirect('/forgot-password', email: @user.email)

    email = UserMailer.password_reset_email(@user).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [Configuration.instance.mail_address], email.from
    assert_equal [@user.email], email.to
    assert_equal 'Your request to reset your PSAP password', email.subject
  end

  # GET /new-password

  test 'GETting /new-password without satisfying conditions should redirect to /' do
    get '/new-password'
    assert_redirected_to '/'
  end

  test 'GETting /new-password satisfying conditions should work' do
    @user.password_reset_key = 'cats'
    @user.save!
    get '/new-password', username: @user.username, key: 'cats'
    assert_response :success
  end

  # POST /new-password

  test 'POSTing to /new-password with an invalid username should redirect to /' do
    post_via_redirect('/new-password')
    assert_equal '/', path

    post_via_redirect('/new-password', user: { 'username' => 'sfdasdf' })
    assert_equal '/', path
  end

  test 'following confirmation link should redirect to /signin and set the flash' do
    post_via_redirect('/new-password', user: @user.attributes)
    assert_equal '/signin', path
    assert_equal('Password reset successfully.', flash['success'])
  end

end
