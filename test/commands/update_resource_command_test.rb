require 'test_helper'

class UpdateResourceCommandTest < ActiveSupport::TestCase

  def setup
    @resource = resources(:magna_carta)
    @valid_params = @resource.attributes
    @valid_params.delete('id')
    @valid_params['name'] = 'asdfjkjhasfd'
    @user = users(:normal)
    @remote_ip = '10.0.0.1'
    @valid_command = UpdateResourceCommand.new(@resource, @valid_params,
                                               @user, @remote_ip)

    @invalid_params = @valid_params.dup
    @invalid_params['name'] = ''
    @invalid_command = UpdateResourceCommand.new(@resource, @invalid_params,
                                                 @user, @remote_ip)
  end

  # execute
  test 'execute method should save resource if valid' do
    assert_nothing_raised do
      @valid_command.execute
    end
  end

  test 'execute method should fail if validation failed' do
    assert_raises ValidationError do
      @invalid_command.execute
    end
  end

  test 'execute method should update existing AQRs instead of creating new ones' do
    skip 'Need to write this'
  end

  # object
  test 'object method should return the Resource object' do
    assert_kind_of Resource, @valid_command.object
  end

end
