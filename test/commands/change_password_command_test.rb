require 'test_helper'

class ChangePasswordCommandTest < ActiveSupport::TestCase

  def setup
    @current_password = 'cats11'
    @new_password = 'dogs11'
    @password_confirmation = 'dogs11'
    @user = users(:normal_user)
    @user.password = @current_password
    @doing_user = users(:admin_user)
    @remote_ip = '10.0.0.1'
    @command = ChangePasswordCommand.new(@user, @current_password,
                                         @new_password, @password_confirmation,
                                         @doing_user, @remote_ip)
  end

  # execute
  test 'execute method should allow admin user to change password if valid' do
    old_digest = @user.password_digest
    assert_nothing_raised do
      @command.execute
    end
    assert_not_equal old_digest, @user.password_digest
  end

  test 'execute method should allow normal user to change own password if valid' do
    @doing_user = users(:normal_user)
    @command = ChangePasswordCommand.new(@user, @current_password,
                                         @new_password, @password_confirmation,
                                         @doing_user, @remote_ip)
    old_digest = @user.password_digest
    assert_nothing_raised do
      @command.execute
    end
    assert_not_equal old_digest.inspect, @user.password_digest.inspect
  end

  test 'execute method should fail if non-admin user attempts to change another user\'s password' do
    @doing_user = users(:normal_user)
    @user = users(:unconfirmed_user)
    @command = ChangePasswordCommand.new(@user, @current_password,
                                         @new_password, @password_confirmation,
                                         @doing_user, @remote_ip)
    assert_raises RuntimeError do
      @command.execute
    end
  end

  test 'execute method should fail if current and new passwords are equal' do
    @command = ChangePasswordCommand.new(@user, 'dogs', 'dogs', 'dogs',
                                         @doing_user, @remote_ip)
    old_digest = @user.password_digest
    assert_raises RuntimeError do
      @command.execute
    end
    assert_equal old_digest.inspect, @user.password_digest.inspect
  end

  test 'execute method should fail if current password is incorrect' do
    @current_password = 'dfljksadflj'
    @command = ChangePasswordCommand.new(@user, @current_password,
                                         @new_password, @password_confirmation,
                                         @doing_user, @remote_ip)
    assert_raises RuntimeError do
      @command.execute
    end
  end

  test 'execute method should fail if confirmation does not match' do
    @password_confirmation = 'asdlfjkasdf'
    @command = ChangePasswordCommand.new(@user, @current_password,
                                         @new_password, @password_confirmation,
                                         @doing_user, @remote_ip)
    assert_raises RuntimeError do
      @command.execute
    end
  end

  # object
  test 'object method should return the User object' do
    assert_kind_of User, @command.object
  end

end
