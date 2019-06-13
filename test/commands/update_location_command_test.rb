require 'test_helper'

class UpdateLocationCommandTest < ActiveSupport::TestCase

  def setup
    @location = locations(:location_one)
    @valid_params = locations(:location_one).attributes
    @valid_params.delete('id')
    @valid_params['name'] = 'asdfjkjhasfd'
    @user = users(:normal_user)
    @remote_ip = '10.0.0.1'
    @valid_command = UpdateLocationCommand.new(@location, @valid_params,
                                               @user, @remote_ip)

    @invalid_params = @valid_params.dup
    @invalid_params['name'] = ''
    @invalid_command = UpdateLocationCommand.new(@location, @invalid_params,
                                                 @user, @remote_ip)
  end

  # execute
  test 'execute method should save location if valid' do
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
  test 'object method should return the Location object' do
    assert_kind_of Location, @valid_command.object
  end

end
