require 'test_helper'

class JoinInstitutionCommandTest < ActiveSupport::TestCase

  def setup
    @institution = institutions(:institution_one)
    @user = users(:unaffiliated_user)
    @remote_ip = '10.0.0.1'
    @command = JoinInstitutionCommand.new(@user, @institution, @user,
                                          @remote_ip)
  end

  # execute
  test 'execute method should not raise errors if valid' do
    assert_nothing_raised do
      assert_difference 'Event.count' do
        @command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "Joined institution \"#{@command.object.name}\"",
                 event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'execute command should do nothing if the user is already a member of the institution' do
    initial_institution = @user.institution
    @command.execute
    assert_equal initial_institution, @user.institution
  end

  test 'admin users can change anyone\'s institution' do
    skip # TODO: write this
  end

  test 'non-admin users cannot change other users\' institutions' do
    skip # TODO: write this
  end

  test 'non-admin users\' institution change requires review' do
    skip # TODO: write this
  end

  # object
  test 'object method should return the Institution object' do
    assert @institution == @command.object
  end

end
