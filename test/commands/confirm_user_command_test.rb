require 'test_helper'

class ConfirmUserCommandTest < ActiveSupport::TestCase

  def setup
    @user = users(:unconfirmed_user)
    @confirmation_code = 'supplied code'
    @remote_ip = '10.0.0.1'
    @command = ConfirmUserCommand.new(@user, @confirmation_code, @remote_ip)
  end

  # execute
  test 'execute method should confirm user if valid' do
    @user.confirmation_code = 'supplied code'
    assert_nothing_raised do
      assert_difference 'Event.count' do
        @command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "Confirmed user #{@command.object.username}",
                 event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'execute method should fail if confirmation code is incorrect' do
    @user.confirmation_code = 'zzzkjzkjzlkjzlkj'
    assert_raises RuntimeError do
      assert_difference 'Event.count' do
        @command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "Invalid confirmation code supplied for user "\
    "#{@command.object.username}",
                 event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'execute method should fail if user is already confirmed' do
    @user = users(:normal_user)
    @user.confirmation_code = 'cats'
    @confirmation_code = 'cats'
    @remote_ip = '10.0.0.1'
    @command = ConfirmUserCommand.new(@user, @confirmation_code, @remote_ip)

    assert_raises RuntimeError do
      assert_difference 'Event.count' do
        @command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "User #{@user.username} attempted to confirm account, but "\
    "was already confirmed.",
                 event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  # object
  test 'object method should return the created User object' do
    assert_kind_of User, @command.object
  end

end
