require 'test_helper'

class CreateUserCommandTest < ActiveSupport::TestCase

  def setup
    @valid_user_params = {
        'username' => 'newuser',
        'first_name' => 'Bob',
        'last_name' => 'Bob',
        'email' => 'newuser@example.org',
        'password' => 'catscatscats',
        'password_confirmation' => 'catscatscats',
        'about' => 'about me'
    }
    @remote_ip = '10.0.0.1'
    @valid_command = CreateUserCommand.new(@valid_user_params, @remote_ip)

    @invalid_user_params = @valid_user_params.except('username')
    @invalid_command = CreateUserCommand.new(@invalid_user_params, @remote_ip)
  end

  # execute
  test 'execute method should save user if valid' do
    assert_nothing_raised do
      @valid_command.execute
    end
  end

  test 'execute method should fail if validation failed' do
    assert_raises ValidationError do
      @invalid_command.execute
    end
  end

  # object
  test 'object method should return the created User object' do
    assert_kind_of User, @valid_command.object
  end

end
