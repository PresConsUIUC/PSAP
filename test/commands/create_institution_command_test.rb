require 'test_helper'

class CreateInstitutionCommandTest < ActiveSupport::TestCase

  def setup
    @valid_institution_params = institutions(:institution_one).attributes
    @valid_institution_params['id'] = nil
    @valid_institution_params['name'] = 'asdfasfd'
    @user = users(:normal_user)
    @remote_ip = '10.0.0.1'
    @valid_command = CreateInstitutionCommand.new(@valid_institution_params,
                                                  @user, @remote_ip)

    @invalid_institution_params = @valid_institution_params.dup.except('name')
    @invalid_command = CreateInstitutionCommand.new(@invalid_institution_params,
                                                    @user, @remote_ip)
  end

  # execute
  test 'execute method should save institution if valid' do
    assert_nothing_raised do
      assert_difference 'Event.count' do
        @valid_command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "Created institution \"#{@valid_command.object.name}\"",
                 event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'execute method should fail if validation failed' do
    assert_raises RuntimeError do
      assert_difference 'Event.count' do
        @invalid_command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "Attempted to create institution, but failed: Name can't be "\
    "blank",
                 event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  # object
  test 'object method should return the created Institution object' do
    assert_kind_of Institution, @valid_command.object
  end

end
