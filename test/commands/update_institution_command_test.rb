require 'test_helper'

class UpdateInstitutionCommandTest < ActiveSupport::TestCase

  def setup
    @institution = institutions(:one)
    @valid_params = institutions(:one).attributes
    @valid_params.delete('id')
    @valid_params['name'] = 'asdfjkjhasfd'
    @user = users(:normal)
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
      @valid_command.execute
    end
  end

  test 'execute method should fail if validation failed' do
    assert_raises ValidationError do
      @invalid_command.execute
    end
  end

  # object
  test 'object method should return the Institution object' do
    assert_kind_of Institution, @valid_command.object
  end

end
