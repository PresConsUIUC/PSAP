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
      @command.execute
    end
  end

  test 'execute method should fail if confirmation code is incorrect' do
    @user.confirmation_code = 'zzzkjzkjzlkjzlkj'
    assert_raises RuntimeError do
      @command.execute
    end
  end

  test 'execute method should fail if user is already confirmed' do
    @user = users(:normal_user)
    @user.confirmation_code = 'cats'
    @confirmation_code = 'cats'
    @remote_ip = '10.0.0.1'
    @command = ConfirmUserCommand.new(@user, @confirmation_code, @remote_ip)

    assert_raises RuntimeError do
      @command.execute
    end
  end

  # object
  test 'object method should return the created User object' do
    assert_kind_of User, @command.object
  end

end
