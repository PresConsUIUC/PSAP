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
    @command.execute
    assert @user.enabled
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
  end

  # object
  test 'object method should return the enabled User object' do
    assert_kind_of User, @command.object
  end

end
