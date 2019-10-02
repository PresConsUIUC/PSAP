require 'test_helper'

class CreateInstitutionCommandTest < ActiveSupport::TestCase

  def setup
    @valid_institution_params = institutions(:one).attributes
    @valid_institution_params['id'] = nil
    @valid_institution_params['name'] = 'asdfasfd'
    @user = users(:normal)
    @remote_ip = '10.0.0.1'
    @valid_command = CreateInstitutionCommand.new(
        @valid_institution_params, @user, @remote_ip)

    @invalid_institution_params = @valid_institution_params.dup.except('name')
    @invalid_command = CreateInstitutionCommand.new(
        @invalid_institution_params, @user, @remote_ip)
  end

  # execute
  test 'execute method should save institution if valid' do
    assert_nothing_raised do
      @valid_command.execute
    end
  end

  test 'execute method should fail if validation failed' do
    assert_raises ValidationError do
      @invalid_command.execute
    end
  end

  # object
  test 'object method should return the created Institution object' do
    assert_kind_of Institution, @valid_command.object
  end

end
