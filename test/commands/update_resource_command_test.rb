require 'test_helper'

class UpdateResourceCommandTest < ActiveSupport::TestCase

  def setup
    @resource = resources(:resource_one)
    @valid_params = resources(:resource_one).attributes
    @valid_params.delete('id')
    @valid_params['name'] = 'asdfjkjhasfd'
    @user = users(:normal_user)
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
      assert_difference 'Event.count' do
        @valid_command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "Updated resource \"#{@valid_command.object.name}\" in "\
    "location \"#{@valid_command.object.location.name}\"",
                 event.description
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
    assert_equal "Attempted to update resource \"#{@resource.name},\" "\
    "but failed: Name can't be blank",
                 event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  # object
  test 'object method should return the Resource object' do
    assert_kind_of Resource, @valid_command.object
  end

end
