require 'test_helper'

class UpdateInstitutionCommandTest < ActiveSupport::TestCase

  def setup
    @institution = institutions(:institution_one)
    @valid_params = institutions(:institution_one).attributes
    @valid_params.delete('id')
    @valid_params['name'] = 'asdfjkjhasfd'
    @user = users(:normal_user)
    @remote_ip = '10.0.0.1'
    @valid_command = UpdateInstitutionCommand.new(@institution, @valid_params,
                                                  @user, @remote_ip)

    @invalid_params = @valid_params.dup
    @invalid_params['name'] = ''
    @invalid_command = UpdateInstitutionCommand.new(@institution,
                                                    @invalid_params, @user,
                                                    @remote_ip)
  end

  # execute
  test 'execute method should save institution if valid' do
    assert_nothing_raised do
      assert_difference 'Event.count' do
        @valid_command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "Updated institution \"#{@valid_command.object.name}\"",
                 event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'execute method should fail if validation failed' do
    assert_raises ValidationError do
      assert_difference 'Event.count' do
        @invalid_command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "Attempted to update institution \"#{@institution.name},\" "\
    "but failed: Name can't be blank",
                 event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  # object
  test 'object method should return the Institution object' do
    assert_kind_of Institution, @valid_command.object
  end

end
