require 'test_helper'

class ImportArchivesspaceEadCommandTest < ActiveSupport::TestCase

  def setup
    @files = [
        File.open('test/commands/ead1.xml', 'r'),
        File.open('test/commands/ead2.xml', 'r')
    ]
    @parent_resource = resources(:uiuc_collection)
    @location = locations(:secret)
    @user = users(:normal)
    @remote_ip = '10.0.0.1'

    @valid_command = ImportArchivesspaceEadCommand.new(
        @files, @parent_resource, @location, @user, @remote_ip)
  end

  # execute
  test 'execute method should create resources if valid' do
    assert_nothing_raised do
      @valid_command.execute
    end
  end

  # object
  test 'object method should return the created Resource objects' do
    @valid_command.execute
    assert_kind_of Resource, @valid_command.object[0]
    assert_kind_of Resource, @valid_command.object[1]
  end

end
