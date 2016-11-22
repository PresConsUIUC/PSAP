require 'test_helper'

class SendConfirmationEmailCommandTest < ActiveSupport::TestCase

  def setup
    @user = users(:normal_user)
    @doing_user = users(:admin_user)
    @remote_ip = '10.0.0.1'

    @command = SendConfirmationEmailCommand.new(@user, @doing_user, @remote_ip)
  end

  # execute
  test 'execute method should send confirmation email' do
    @command.execute
    assert !ActionMailer::Base.deliveries.empty?
  end

  test 'execute method should write success to event log if successful' do
    assert_difference 'Event.count' do
      @command.execute
    end
    event = Event.order(:created_at).last
    assert_equal "Sent confirmation email to user #{@user.username}",
                 event.description
    assert_equal @doing_user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'execute method should write failure to event log if unsuccessful' do
    skip 'Need to get this to happen'
  end

  test 'non-admin users should not be able to send confirmation emails' do
    @doing_user = users(:normal_user)
    @user = users(:admin_user)

    @command = SendConfirmationEmailCommand.new(@user, @doing_user, @remote_ip)
    assert_raises RuntimeError do
      @command.execute
    end
    event = Event.order(:created_at).last
    assert_equal "Attempted to send a confirmation email to user "\
    "#{@user.username}, but failed: Insufficient privileges", event.description
    assert_equal @doing_user, event.user
    assert_equal @remote_ip, event.address
  end

  # object
  test 'object method should return the User object' do
    assert_kind_of User, @command.object
  end

end
