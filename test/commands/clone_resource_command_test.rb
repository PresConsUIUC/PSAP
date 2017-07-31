require 'test_helper'

##
# Tests only the cloning action; model-level validation is handled in
# ResourceTest.
#
class CloneResourceCommandTest < ActiveSupport::TestCase

  def setup
    @resource = resources(:resource_one)
    @doing_user = users(:admin_user)
    @remote_ip = '10.0.0.1'
    @command = CloneResourceCommand.new(@resource, false, @doing_user, @remote_ip)
  end

  # execute
  test 'execute method should not raise errors' do
    assert_nothing_raised do
      @command.execute
    end
  end

  test 'execute method should write success to event log if successful' do
    assert_difference 'Event.count', 2 do
      @command.execute
    end
    event = Event.order(:created_at).last
    assert event.description.include?('Cloned')
    assert_equal @doing_user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'execute method should write failure to event log if unsuccessful' do
    skip 'Need to get this to happen'
  end

  test 'execute method should attach an event to both resources' do
    @command.execute
    assert_equal 1, @resource.events.length
    assert_equal 1, @command.object.events.length
  end

  # object
  test 'object method should return the cloned Resource object' do
    assert_kind_of Resource, @command.object
    assert_not_equal @command.object, @resource
  end

end
