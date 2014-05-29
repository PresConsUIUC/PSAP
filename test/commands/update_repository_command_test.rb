require 'test_helper'

class UpdateRepositoryCommandTest < ActiveSupport::TestCase

  def setup
    @repository = repositories(:repository_one)
    @valid_params = repositories(:repository_one).attributes
    @valid_params.delete('id')
    @valid_params['name'] = 'asdfjkjhasfd'
    @user = users(:normal_user)
    @remote_ip = '10.0.0.1'
    @valid_command = UpdateRepositoryCommand.new(@repository, @valid_params,
                                                 @user, @remote_ip)

    @invalid_params = @valid_params.dup
    @invalid_params['name'] = ''
    @invalid_command = UpdateRepositoryCommand.new(@repository, @invalid_params,
                                                   @user, @remote_ip)
  end

  # execute
  test 'execute method should save repository if valid' do
    assert_nothing_raised do
      assert_difference 'Event.count' do
        @valid_command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "Updated repository \"#{@valid_command.object.name}\" in "\
    "institution \"#{@valid_command.object.institution.name}\"",
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
    assert_equal "Attempted to update repository \"#{@repository.name},\" "\
    "but failed: Name can't be blank",
                 event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  # object
  test 'object method should return the Repository object' do
    assert_kind_of Repository, @valid_command.object
  end

end
