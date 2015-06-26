require 'test_helper'

class AdminMailerTest < ActionMailer::TestCase

  tests AdminMailer

  test 'account_approval_request_email' do
    # Send the email, then test that it got queued
    email = AdminMailer.account_approval_request_email(users(:unconfirmed_user)).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [Psap::Application.config.psap_email_address], email.from
    assert_equal [Psap::Application.config.psap_email_address], email.to
    assert_equal 'New PSAP user requests account approval', email.subject
    assert_equal read_fixture('account_approval_request_email.txt').join,
                 email.text_part.body.raw_source
    assert_equal read_fixture('account_approval_request_email.html').join,
                 email.html_part.body.raw_source
  end

  test 'institution_change_review_request_email' do
    # Send the email, then test that it got queued
    user = users(:normal_user)
    user.desired_institution = institutions(:institution_two)
    email = AdminMailer.institution_change_review_request_email(user).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [Psap::Application.config.psap_email_address], email.from
    assert_equal [Psap::Application.config.psap_email_address], email.to
    assert_equal 'PSAP user requests to change institutions', email.subject
    assert_equal read_fixture('institution_change_review_request_email.txt').join,
                 email.text_part.body.raw_source
    assert_equal read_fixture('institution_change_review_request_email.html').join,
                 email.html_part.body.raw_source
  end

end
