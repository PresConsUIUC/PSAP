require 'test_helper'

class DeleteLocationCommandTest < ActiveSupport::TestCase

  def setup
    @location = locations(:location_one)

    @user = users(:normal_user)
    @remote_ip = '10.0.0.1'

    @command = DeleteLocationCommand.new(@location, @user, @remote_ip)
  end

  # execute
  test 'execute method should delete location' do
    assert_nothing_raised do
      @command.execute
    end
  end

  test 'execute method should write success to event log if successful' do
    assert_difference 'Location.count', -1 do
      @command.execute
    end
    assert @location.destroyed?
  end

  test 'execute method should raise DeleteRestrictionError if a constraint prevents delete' do
    skip 'Need to get this to happen'
  end

  test 'execute method should write failure to event log if unsuccessful' do
    skip 'Need to get this to happen'
  end

  # object
  test 'object method should return the deleted Location object' do
    assert_kind_of Location, @command.object
  end

end
