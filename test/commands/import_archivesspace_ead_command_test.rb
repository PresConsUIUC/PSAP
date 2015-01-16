require 'test_helper'

class ImportArchivesspaceEadCommandTest < ActiveSupport::TestCase

  def setup
    @files = [
        File.open('test/commands/ead1.xml', 'r'),
        File.open('test/commands/ead2.xml', 'r')
    ]
    @parent_resource = resources(:uiuc_collection)
    @user = users(:normal_user)
    @remote_ip = '10.0.0.1'

    @valid_command = ImportArchivesspaceEadCommand.new(
        @files, @parent_resource, @user, @remote_ip)
  end

  # execute
  test 'execute method should create resources if valid' do
    assert_nothing_raised do
      assert_difference 'Event.count', 2 do
        @valid_command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "Imported resource \"Another Collection\" from ArchivesSpace",
                 event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  # object
  test 'object method should return the created Resource objects' do
    @valid_command.execute
    assert_kind_of Resource, @valid_command.object[0]
    assert_kind_of Resource, @valid_command.object[1]
  end

end
