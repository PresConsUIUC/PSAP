require 'test_helper'

class ResetUserFeedKeyCommandTest < ActiveSupport::TestCase

  def setup
    @user = users(:normal_user)
    @doing_user = users(:admin_user)
    @remote_ip = '10.0.0.1'

    @command = ResetUserFeedKeyCommand.new(@user, @doing_user, @remote_ip)
  end

  # execute
  test 'execute method should reset feet key' do
    key = @user.feed_key.dup
    assert_nothing_raised do
      @command.execute
    end
    assert_not_equal key, @user.feed_key
  end

  test 'execute method should write success to event log if successful' do
    assert_difference 'Event.count' do
      @command.execute
    end
    event = Event.order(:created_at).last
    assert_equal "Reset feed key for user #{@user.username}", event.description
    assert_equal @doing_user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'execute method should write failure to event log if unsuccessful' do
    flunk 'Need to get this to happen'
  end

  test 'non-admin users should not be able to reset other users\' feed keys' do
    @doing_user = users(:normal_user)
    @user = users(:admin_user)
    key = @user.feed_key.dup
    @command = ResetUserFeedKeyCommand.new(@user, @doing_user, @remote_ip)
    assert_raises RuntimeError do
      @command.execute
    end
    assert_equal key, @user.feed_key
    event = Event.order(:created_at).last
    assert_equal "Attempted to reset feed key for user #{@user.username}, but "\
    "failed: Insufficient privileges",
                 event.description
    assert_equal @doing_user, event.user
    assert_equal @remote_ip, event.address
  end

  # object
  test 'object method should return the User object' do
    assert_kind_of User, @command.object
  end

end
