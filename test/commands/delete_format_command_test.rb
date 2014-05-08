require 'test_helper'

class DeleteFormatCommandTest < ActiveSupport::TestCase

  def setup
    @format = Format.create!(name: 'test', score: 0, obsolete: false)

    @user = users(:normal_user)
    @remote_ip = '10.0.0.1'

    @command = DeleteFormatCommand.new(@format, @user, @remote_ip)
  end

  # execute
  test 'execute method should delete format' do
    assert_nothing_raised do
      @command.execute
    end
  end

  test 'execute method should write success to event log if successful' do
    assert_difference 'Event.count' do
      assert_difference 'Format.count', -1 do
        @command.execute
      end
    end
    assert @format.destroyed?
    event = Event.order(:created_at).last
    assert_equal "Deleted format \"#{@format.name}\"", event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'execute method should raise DeleteRestrictionError if a constraint prevents delete' do
    @format = formats(:format_one)
    @command = DeleteFormatCommand.new(@format, @user, @remote_ip)

    assert_raises ActiveRecord::DeleteRestrictionError do
      assert_difference 'Event.count' do
        @command.execute
      end
    end
    assert !@format.destroyed?
    event = Event.order(:created_at).last
    assert_equal 'Failed to delete format: Cannot delete record because of dependent resources',
                 event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'execute method should write failure to event log if unsuccessful' do
    skip 'Need to get this to happen'
  end

  # object
  test 'object method should return the deleted Format object' do
    assert_kind_of Format, @command.object
  end

end
