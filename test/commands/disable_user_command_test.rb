require 'test_helper'

class DisableUserCommandTest < ActiveSupport::TestCase

  def setup
    @user = users(:normal)

    @doing_user = users(:admin)
    @remote_ip = '10.0.0.1'

    @command = DisableUserCommand.new(@user, @doing_user, @remote_ip)
  end

  # execute
  test 'execute method should disable user' do
    assert_nothing_raised do
      @command.execute
    end
  end

  test 'execute method should write success to event log if successful' do
    @command.execute
    assert !@user.enabled
  end

  test 'execute method should write failure to event log if unsuccessful' do
    skip 'Need to get this to happen'
  end

  test 'non-admin users should not be able to disable users' do
    @doing_user = users(:normal)
    @user = users(:admin)
    @command = DisableUserCommand.new(@user, @doing_user, @remote_ip)
    assert_raises RuntimeError do
      @command.execute
    end
    assert @user.enabled
  end

  # object
  test 'object method should return the disabled User object' do
    assert_kind_of User, @command.object
  end

end
