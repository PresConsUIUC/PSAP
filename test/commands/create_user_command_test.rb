require 'test_helper'

class CreateUserCommandTest < ActiveSupport::TestCase

  def setup
    @valid_user_params = {
        'username' => 'newuser',
        'first_name' => 'Bob',
        'last_name' => 'Bob',
        'email' => 'newuser@example.org',
        'password' => 'catscatscats',
        'password_confirmation' => 'catscatscats'
    }
    @remote_ip = '10.0.0.1'
    @valid_command = CreateUserCommand.new(@valid_user_params, @remote_ip)

    @invalid_user_params = @valid_user_params.dup.except('username')
    @invalid_command = CreateUserCommand.new(@invalid_user_params, @remote_ip)
  end

  # execute
  test 'execute method should save user if valid' do
    assert_nothing_raised do
      assert_difference 'Event.count' do
        @valid_command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "Created account for user #{@valid_command.object.username}",
                 event.description
    assert_equal @valid_command.object, event.user
    assert_equal @remote_ip, event.address
  end

  test 'execute method should fail if validation failed' do
    assert_raises RuntimeError do
      assert_difference 'Event.count' do
        @invalid_command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "Attempted to create a user account, but failed: Username "\
    "can't be blank",
                 event.description
    assert_nil event.user
    assert_equal @remote_ip, event.address
  end

  # object
  test 'object method should return the created User object' do
    assert_kind_of User, @valid_command.object
  end

end
