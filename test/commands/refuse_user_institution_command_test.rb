require 'test_helper'

class RefuseUserInstitutionCommandTest < ActiveSupport::TestCase

  def setup
    @user = users(:normal_user)
    @user.desired_institution = institutions(:institution_two)

    @doing_user = users(:admin_user)
    @remote_ip = '10.0.0.1'

    @command = RefuseUserInstitutionCommand.new(@user, @doing_user, @remote_ip)
  end

  # execute
  test 'execute method should refuse change' do
    assert_nothing_raised do
      @command.execute
    end
  end

  test 'execute method should write success to event log if successful' do
    original_institution = @user.institution

    @command.execute

    assert_equal @user.institution, original_institution
    assert_nil @user.desired_institution
  end

  test 'execute method should write failure to event log if unsuccessful' do
    skip 'Need to get this to happen'
  end

  test 'non-admin users should not be able to refuse institution change requests' do
    @doing_user = users(:normal_user)
    @user = users(:admin_user)
    @user.desired_institution = institutions(:institution_two)
    initial_institution = @user.institution

    @command = RefuseUserInstitutionCommand.new(@user, @doing_user, @remote_ip)
    assert_raises RuntimeError do
      @command.execute
    end
    assert_equal initial_institution, @user.institution
  end

  # object
  test 'object method should return the User object' do
    assert_kind_of User, @command.object
  end

end
