require 'test_helper'

class CreateLocationCommandTest < ActiveSupport::TestCase

  def setup
    @repository = repositories(:repository_one)
    @valid_location_params = locations(:location_one).attributes.except(
        'id', 'repository_id')
    @user = users(:normal_user)
    @remote_ip = '10.0.0.1'
    @valid_command = CreateLocationCommand.new(@repository,
                                               @valid_location_params, @user,
                                               @remote_ip)

    @invalid_location_params = @valid_location_params.dup.except('name')
    @invalid_command = CreateLocationCommand.new(@repository,
                                                 @invalid_location_params,
                                                 @user,
                                                 @remote_ip)

    Location.destroy_all
  end

  # execute
  test 'execute method should save location if valid' do
    assert_nothing_raised do
      @valid_command.execute
    end
  end

  test 'execute method should fail if user attempts to create a location in another institution' do
    @repository = repositories(:repository_five)
    @valid_command = CreateLocationCommand.new(@repository,
                                               @valid_location_params, @user,
                                               @remote_ip)
    assert_raises RuntimeError do
      @valid_command.execute
    end
  end

  test 'execute method should fail if validation failed' do
    assert_raises ValidationError do
      @invalid_command.execute
    end
  end

  # object
  test 'object method should return the created Location object' do
    assert_kind_of Location, @valid_command.object
  end

end
