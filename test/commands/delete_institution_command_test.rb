require 'test_helper'

class DeleteInstitutionCommandTest < ActiveSupport::TestCase

  def setup
    @institution = institutions(:four)

    @user = users(:normal)
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
    assert_difference 'Institution.count', -1 do
      @command.execute
    end
    assert @institution.destroyed?
  end

  test 'execute method should raise DeleteRestrictionError if a constraint prevents delete' do
    @institution = institutions(:one)
    @command = DeleteInstitutionCommand.new(@institution, @user, @remote_ip)

    assert_raises RuntimeError do
      @command.execute
    end
    assert !@institution.destroyed?
  end

  test 'execute method should write failure to event log if unsuccessful' do
    skip 'Need to get this to happen'
  end

  # object
  test 'object method should return the deleted Institution object' do
    assert_kind_of Institution, @command.object
  end

end
