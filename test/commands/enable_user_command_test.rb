require 'test_helper'

class EnableUserCommandTest < ActiveSupport::TestCase

  def setup
    @user = users(:normal_user)

    @doing_user = users(:admin_user)
    @remote_ip = '10.0.0.1'

    @command = EnableUserCommand.new(@user, @doing_user, @remote_ip)
  end

  # execute
  test 'execute method should enable user' do
    assert_nothing_raised do
      @command.execute
    end
  end

  test 'execute method should write success to event log if successful' do
    assert_difference 'Event.count' do
      @command.execute
    end
    assert @user.enabled
    event = Event.order(:created_at).last
    assert_equal "Enabled user #{@user.username}", event.description
    assert_equal @doing_user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'execute method should write failure to event log if unsuccessful' do
    skip 'Need to get this to happen'
  end

  test 'non-admin users should not be able to enable users' do
    @doing_user = users(:normal_user)
    @user = users(:admin_user)
    @command = EnableUserCommand.new(@user, @doing_user, @remote_ip)
    assert_raises RuntimeError do
      @command.execute
    end
    assert @user.enabled
    event = Event.order(:created_at).last
    assert_equal "Failed to enable user #{@user.username}: "\
    "#{@doing_user.username} has insufficient privileges to enable users.",
                 event.description
    assert_equal @doing_user, event.user
    assert_equal @remote_ip, event.address
  end

  # object
  test 'object method should return the enabled User object' do
    assert_kind_of User, @command.object
  end

end
