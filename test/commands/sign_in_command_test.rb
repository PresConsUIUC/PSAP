require 'test_helper'

class SignInCommandTest < ActiveSupport::TestCase

  def setup
    users(:normal_user).password = 'catscatscats'
    users(:normal_user).password_confirmation = 'catscatscats'
    users(:normal_user).save!

    @username = 'normal'
    @password = 'catscatscats'
    @remote_ip = '10.0.0.1'

    @command = SignInCommand.new(@username, @password, @remote_ip)
  end

  # execute
  test 'execute method should work if username and password are valid' do
    assert_nothing_raised do
      assert_difference 'Event.count' do
        @command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "User #{@username} signed in", event.description
    assert_equal @username, event.user.username
    assert_equal @remote_ip, event.address
  end

  test 'execute method should write failure to event log if username or password are incorrect' do
    @command = SignInCommand.new(@username, 'dogs', @remote_ip)
    assert_raises RuntimeError do
      assert_difference 'Event.count' do
        @command.execute
      end
    end
  end

  test 'execute method should write failure to event log if no username provided' do
    @command = SignInCommand.new('', @password, @remote_ip)
    assert_raises RuntimeError do
      assert_difference 'Event.count' do
        @command.execute
      end
    end
  end

  # object
  test 'object method should return the signed-in User object' do
    @command.execute
    assert_kind_of User, @command.object
  end

end
