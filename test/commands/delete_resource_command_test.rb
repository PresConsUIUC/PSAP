require 'test_helper'

class DeleteResourceCommandTest < ActiveSupport::TestCase

  def setup
    @resource = resources(:resource_one)

    @user = users(:normal_user)
    @remote_ip = '10.0.0.1'

    @command = DeleteResourceCommand.new(@resource, @user, @remote_ip)
  end

  # execute
  test 'execute method should delete resource' do
    assert_nothing_raised do
      @command.execute
    end
  end

  test 'execute method should write success to event log if successful' do
    assert_difference 'Event.count' do
      assert_difference 'Resource.count', -1 do
        @command.execute
      end
    end
    assert @resource.destroyed?
    event = Event.order(:created_at).last
    assert_equal "Deleted resource \"#{@resource.name}\" from "\
      "location \"#{@resource.location.name}\"", event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'execute method should raise DeleteRestrictionError if a constraint prevents delete' do
    flunk 'Need to get this to happen'
  end

  test 'execute method should write failure to event log if unsuccessful' do
    flunk 'Need to get this to happen'
  end

  # object
  test 'object method should return the deleted Resource object' do
    assert_kind_of Resource, @command.object
  end

end
