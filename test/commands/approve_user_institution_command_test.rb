require 'test_helper'

class ApproveUserInstitutionCommandTest < ActiveSupport::TestCase

  def setup
    @user = users(:normal_user)
    @user.desired_institution = institutions(:institution_two)

    @doing_user = users(:admin_user)
    @remote_ip = '10.0.0.1'

    @command = ApproveUserInstitutionCommand.new(@user, @doing_user, @remote_ip)
  end

  # execute
  test 'execute method should approve change' do
    assert_nothing_raised do
      @command.execute
    end
  end

  test 'non-admin users should not be able to approve institution change requests' do
    @doing_user = users(:normal_user)
    @user = users(:admin_user)
    @user.desired_institution = institutions(:institution_two)
    initial_institution = @user.institution

    @command = ApproveUserInstitutionCommand.new(@user, @doing_user, @remote_ip)
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
