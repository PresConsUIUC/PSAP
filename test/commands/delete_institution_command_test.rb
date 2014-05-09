require 'test_helper'

class DeleteInstitutionCommandTest < ActiveSupport::TestCase

  def setup
    @institution = institutions(:institution_four)

    @user = users(:normal_user)
    @remote_ip = '10.0.0.1'

    @command = DeleteInstitutionCommand.new(@institution, @user, @remote_ip)
  end

  # execute
  test 'execute method should delete location' do
    assert_nothing_raised do
      @command.execute
    end
  end

  test 'execute method should write success to event log if successful' do
    assert_difference 'Event.count' do
      assert_difference 'Institution.count', -1 do
        @command.execute
      end
    end
    assert @institution.destroyed?
    event = Event.order(:created_at).last
    assert_equal "Deleted institution \"#{@institution.name}\"", event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'execute method should raise DeleteRestrictionError if a constraint prevents delete' do
    @institution = institutions(:institution_one)
    @command = DeleteInstitutionCommand.new(@institution, @user, @remote_ip)

    assert_raises RuntimeError do
      assert_difference 'Event.count' do
        @command.execute
      end
    end
    assert !@institution.destroyed?
    event = Event.order(:created_at).last
    assert_equal 'Attempted to delete institution "University of Illinois '\
    'at Urbana-Champaign," but failed as there are one or more users '\
    'affiliated with it.',
                 event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'execute method should write failure to event log if unsuccessful' do
    skip 'Need to get this to happen'
  end

  # object
  test 'object method should return the deleted Institution object' do
    assert_kind_of Institution, @command.object
  end

end
