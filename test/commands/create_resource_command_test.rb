require 'test_helper'

class CreateResourceCommandTest < ActiveSupport::TestCase

  def setup
    @location = locations(:location_one)
    @valid_resource_params = resources(:resource_one).attributes.except(
        'id', 'location_id')
    @user = users(:normal_user)
    @remote_ip = '10.0.0.1'
    @valid_command = CreateResourceCommand.new(@location,
                                               @valid_resource_params,
                                               @user, @remote_ip)

    @invalid_resource_params = @valid_resource_params.dup.except('name')
    @invalid_command = CreateResourceCommand.new(@location,
                                                 @invalid_resource_params,
                                                 @user, @remote_ip)
  end

  # execute
  test 'execute method should save resource if valid' do
    assert_nothing_raised do
      assert_difference 'Event.count' do
        @valid_command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "Created resource \"#{@valid_command.object.name}\" in "\
      "location \"#{@location.name}\"", event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'execute method should fail if user attempts to create a resource in another institution' do
    @valid_command = CreateResourceCommand.new(locations(:location_two),
                                               @valid_resource_params,
                                               @user, @remote_ip)
    assert_raises RuntimeError do
      assert_difference 'Event.count' do
        @valid_command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "Attempted to create resource, but failed: Insufficient "\
    "privileges", event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'execute method should fail if validation failed' do
    assert_raises ValidationError do
      assert_difference 'Event.count' do
        @invalid_command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "Attempted to create resource, but failed: Name can't be "\
    "blank",
                 event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  # object
  test 'object method should return the created Resource object' do
    assert_kind_of Resource, @valid_command.object
  end

end
