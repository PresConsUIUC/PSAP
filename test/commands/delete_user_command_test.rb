require 'test_helper'

class DeleteUserCommandTest < ActiveSupport::TestCase

  def setup
    @user = users(:normal_user)

    @doing_user = users(:admin_user)
    @remote_ip = '10.0.0.1'

    @command = DeleteUserCommand.new(@user, @doing_user, @remote_ip)
  end

  # execute
  test 'execute method should delete user' do
    assert_difference 'Event.count' do
      assert_difference 'User.count', -1 do
        assert_nothing_raised do
          @command.execute
        end
      end
    end
    assert @user.destroyed?
    event = Event.order(:created_at).last
    assert_equal "Deleted user #{@user.username}", event.description
    assert_equal @doing_user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'execute method should fail if executed by a non-admin user' do
    @command = DeleteUserCommand.new(@user, @user, @remote_ip)
    assert_difference 'Event.count' do
      assert_no_difference 'User.count' do
        assert_raises RuntimeError do
          @command.execute
        end
      end
    end
    assert !@user.destroyed?
    event = Event.order(:created_at).last
    assert_equal "Attempted to delete user #{@user.username}, but failed: "\
    "Insufficient privileges", event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'execute method should write failure to event log if unsuccessful' do
    flunk 'Need to get this to happen'
  end

  # object
  test 'object method should return the deleted User object' do
    assert_kind_of User, @command.object
  end

end
