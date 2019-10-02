require 'test_helper'

class SignOutCommandTest < ActiveSupport::TestCase

  def setup
    @user = users(:normal)
    @remote_ip = '10.0.0.1'

    @command = SignOutCommand.new(@user, @remote_ip)
  end

  # execute
  test 'execute method should work' do
    @command.execute
  end

  # object
  test 'object method should return the signed-out User object' do
    assert_kind_of User, @command.object
  end

end
