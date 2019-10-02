require 'test_helper'

class SignInCommandTest < ActiveSupport::TestCase

  def setup
    users(:normal).password = 'catscatscats'
    users(:normal).password_confirmation = 'catscatscats'
    users(:normal).save!

    @username = 'normal'
    @password = 'catscatscats'
    @remote_ip = '10.0.0.1'

    @command = SignInCommand.new(@username, @password, @remote_ip)
  end

  # execute
  test 'execute method should work if username and password are valid' do
    assert_nothing_raised do
      @command.execute
    end
  end

  test 'execute method should write failure to event log if username or password are incorrect' do
    @command = SignInCommand.new(@username, 'dogs', @remote_ip)
    assert_raises RuntimeError do
      @command.execute
    end
  end

  test 'execute method should write failure to event log if no username provided' do
    @command = SignInCommand.new('', @password, @remote_ip)
    assert_raises RuntimeError do
      @command.execute
    end
  end

  # object
  test 'object method should return the signed-in User object' do
    @command.execute
    assert_kind_of User, @command.object
  end

end
