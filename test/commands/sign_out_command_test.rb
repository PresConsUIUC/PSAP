require 'test_helper'

class SignOutCommandTest < ActiveSupport::TestCase

  def setup
    @user = users(:normal_user)
    @remote_ip = '10.0.0.1'

    @command = SignOutCommand.new(@user, @remote_ip)
  end

  # execute
  test 'execute method should work' do
    assert_difference 'Event.count' do
      @command.execute
    end
    event = Event.order(:created_at).last
    assert_equal "User #{@user.username} signed out", event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  # object
  test 'object method should return the signed-out User object' do
    assert_kind_of User, @command.object
  end

end
