require 'test_helper'

##
# Tests only the cloning action; model-level validation is handled in
# ResourceTest.
#
class CloneResourceCommandTest < ActiveSupport::TestCase

  def setup
    @resource = resources(:magna_carta)
    @doing_user = users(:admin)
    @remote_ip = '10.0.0.1'
    @command = CloneResourceCommand.new(@resource, false, @doing_user, @remote_ip)
  end

  # execute
  test 'execute method should not raise errors' do
    assert_nothing_raised do
      @command.execute
    end
  end

  # object
  test 'object method should return the cloned Resource object' do
    assert_kind_of Resource, @command.object
    assert_not_equal @command.object, @resource
  end

end
