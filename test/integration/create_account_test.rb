require 'test_helper'

class CreateAccountTest < ActionDispatch::IntegrationTest

  setup do
    @new_user_attributes = users(:normal_user).attributes
    @new_user_attributes[:username] = 'test'
    @new_user_attributes[:email] = 'test@example.org'
    @new_user_attributes[:password] = 'catscatscats'
    @new_user_attributes[:password_confirmation] = 'catscatscats'
  end

  test 'create account page should load' do
    get '/users/register'
    assert_response :success
  end

  test 'POSTing a correctly-filled form to /users should redirect to /' do
    post_via_redirect('/users', 'user' => @new_user_attributes)
    assert_redirected_to '/'
  end

  test 'POSTing a correctly-filled form to /users should set the flash' do
    post_via_redirect('/users', 'user' => @new_user_attributes)

    assert_equal('Thanks for registering for PSAP! An email has been sent to '\
    'the address you provided. Follow the link in the email to confirm your '\
    'account.', flash['success'])
  end

  test 'POSTing a correctly-filled form to /users should send an email' do
    post_via_redirect('/users', 'user' => @new_user_attributes)

    email = UserMailer.confirm_account_email(users(:normal_user)).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [Psap::Application.config.psap_email_address], email.from
    assert_equal ['normal@example.org'], email.to
    assert_equal 'Welcome to PSAP!', email.subject
  end

  test 'Email confirmation link should redirect to /signin' do
    post_via_redirect('/users', 'user' => @new_user_attributes)
    get '/users/test/confirm', code: User.find_by_username('test').confirmation_code
    assert_redirected_to '/signin'
  end

  test 'Email confirmation link should confirm the user\'s account' do
    post_via_redirect('/users', 'user' => @new_user_attributes)
    get '/users/test/confirm', code: User.find_by_username('test').confirmation_code
    assert User.find_by_username('test').confirmed
  end

  test 'Email confirmation link should set the flash' do
    post_via_redirect('/users', 'user' => @new_user_attributes)
    get '/users/test/confirm', code: User.find_by_username('test').confirmation_code
    assert_equal('Your account has been confirmed, but before you can '\
      'sign in, it must be approved by an administrator. We\'ll get back to '\
      'you as soon as we can. Thanks for your interest in the PSAP!',
                 flash['success'])
  end

  test 'Email confirmation link should send an email to the administrator' do
    post_via_redirect('/users', 'user' => @new_user_attributes)

    email = AdminMailer.account_approval_request_email(users(:normal_user)).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [Psap::Application.config.psap_email_address], email.from
    assert_equal [Psap::Application.config.psap_email_address], email.to
    assert_equal 'New PSAP user requests account approval', email.subject
  end

end
