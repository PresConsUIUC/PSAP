require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

  tests UserMailer

  test 'change_email' do
    # Send the email, then test that it got queued
    email = UserMailer.change_email(users(:normal_user),
                                    'old@example.org',
                                    'new@example.org').deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [Psap::Application.config.psap_email_address], email.from
    assert_equal ['old@example.org'], email.to
    assert_equal 'Your PSAP email has changed', email.subject
    assert_equal read_fixture('change_email.txt').join,
                 email.text_part.body.raw_source
    assert_equal read_fixture('change_email.html').join,
                 email.html_part.body.raw_source
  end

  test 'changed_feed_key_email' do
    # Send the email, then test that it got queued
    email = UserMailer.changed_feed_key_email(users(:normal_user)).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [Psap::Application.config.psap_email_address], email.from
    assert_equal [users(:normal_user).email], email.to
    assert_equal 'Your PSAP feed key has been changed', email.subject
    assert_equal read_fixture('changed_feed_key_email.txt').join,
                 email.text_part.body.raw_source
    assert_equal read_fixture('changed_feed_key_email.html').join,
                 email.html_part.body.raw_source
  end

  test 'confirm_account_email' do
    # Send the email, then test that it got queued
    email = UserMailer.confirm_account_email(users(:normal_user)).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [Psap::Application.config.psap_email_address], email.from
    assert_equal [users(:normal_user).email], email.to
    assert_equal 'Welcome to PSAP!', email.subject
    assert_equal read_fixture('confirm_account_email.txt').join,
                 email.text_part.body.raw_source
    assert_equal read_fixture('confirm_account_email.html').join,
                 email.html_part.body.raw_source
  end

  test 'institution_change_approved_email' do
    # Send the email, then test that it got queued
    email = UserMailer.institution_change_approved_email(users(:normal_user)).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [Psap::Application.config.psap_email_address], email.from
    assert_equal [users(:normal_user).email], email.to
    assert_equal 'Your new PSAP institution has been approved', email.subject
    assert_equal read_fixture('institution_change_approved_email.txt').join,
                 email.text_part.body.raw_source
    assert_equal read_fixture('institution_change_approved_email.html').join,
                 email.html_part.body.raw_source
  end

  test 'institution_change_refused_email' do
    # Send the email, then test that it got queued
    email = UserMailer.institution_change_refused_email(users(:normal_user)).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [Psap::Application.config.psap_email_address], email.from
    assert_equal [users(:normal_user).email], email.to
    assert_equal 'Your request to change your PSAP institution has been denied',
                 email.subject
    assert_equal read_fixture('institution_change_refused_email.txt').join,
                 email.text_part.body.raw_source
    assert_equal read_fixture('institution_change_refused_email.html').join,
                 email.html_part.body.raw_source
  end

  test 'password_reset_email' do
    # Send the email, then test that it got queued
    email = UserMailer.password_reset_email(users(:normal_user)).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [Psap::Application.config.psap_email_address], email.from
    assert_equal [users(:normal_user).email], email.to
    assert_equal 'Your request to reset your PSAP password', email.subject
    assert_equal read_fixture('password_reset_email.txt').join,
                 email.text_part.body.raw_source
    assert_equal read_fixture('password_reset_email.html').join,
                 email.html_part.body.raw_source
  end

end
