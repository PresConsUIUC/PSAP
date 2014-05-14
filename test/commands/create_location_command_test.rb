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
  end

  # execute
  test 'execute method should save location if valid' do
    assert_nothing_raised do
      assert_difference 'Event.count' do
        @valid_command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "Created location \"#{@valid_command.object.name}\" in "\
      "repository \"#{@repository.name}\"", event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'execute method should fail if user attempts to create a location in another institution' do
    @repository = repositories(:repository_five)
    @valid_command = CreateLocationCommand.new(@repository,
                                               @valid_location_params, @user,
                                               @remote_ip)
    assert_raises RuntimeError do
      assert_difference 'Event.count' do
        @valid_command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "Attempted to create location, but failed: Insufficient "\
    "privileges", event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'execute method should write failure to event log if validation failed' do
    assert_raises RuntimeError do
      assert_difference 'Event.count' do
        @invalid_command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "Attempted to create location, but failed: Name can't be "\
    "blank",
                 event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  # object
  test 'object method should return the created Location object' do
    assert_kind_of Location, @valid_command.object
  end

end
