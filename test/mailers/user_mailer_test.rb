require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

  tests UserMailer

  test 'change_email' do
    # Send the email, then test that it got queued
    email = UserMailer.change_email(users(:normal_user),
                                    'old@example.org',
                                    'new@example.org').deliver
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal ['psapdev@yahoo.com'], email.from
    assert_equal ['old@example.org'], email.to
    assert_equal 'Your PSAP email has changed', email.subject
    assert_equal read_fixture('change_email.txt').join,
                 email.text_part.body.raw_source
    assert_equal read_fixture('change_email.html').join,
                 email.html_part.body.raw_source
  end

  test 'password_reset_email' do
    # Send the email, then test that it got queued
    email = UserMailer.password_reset_email(users(:normal_user)).deliver
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal ['psapdev@yahoo.com'], email.from
    assert_equal [users(:normal_user).email], email.to
    assert_equal 'Your request to reset your PSAP password', email.subject
    assert_equal read_fixture('password_reset_email.txt').join,
                 email.text_part.body.raw_source
    assert_equal read_fixture('password_reset_email.html').join,
                 email.html_part.body.raw_source
  end

  test 'welcome_email' do
    # Send the email, then test that it got queued
    email = UserMailer.welcome_email(users(:normal_user)).deliver
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal ['psapdev@yahoo.com'], email.from
    assert_equal [users(:normal_user).email], email.to
    assert_equal 'Welcome to PSAP!', email.subject
    assert_equal read_fixture('welcome_email.txt').join,
                 email.text_part.body.raw_source
    assert_equal read_fixture('welcome_email.html').join,
                 email.html_part.body.raw_source
  end

end
