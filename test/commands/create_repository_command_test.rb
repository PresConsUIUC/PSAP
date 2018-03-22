require 'test_helper'

class CreateRepositoryCommandTest < ActiveSupport::TestCase

  def setup
    @institution = institutions(:institution_one)
    @valid_repository_params = repositories(:repository_one).attributes.except(
        'id', 'institution_id')
    @user = users(:normal_user)
    @remote_ip = '10.0.0.1'
    @valid_command = CreateRepositoryCommand.new(@institution,
                                                 @valid_repository_params,
                                                 @user, @remote_ip)

    @invalid_repository_params = @valid_repository_params.dup.except('name')
    @invalid_command = CreateRepositoryCommand.new(@institution,
                                                   @invalid_repository_params,
                                                   @user, @remote_ip)

    Repository.destroy_all
  end

  # execute
  test 'execute method should save repository if valid' do
    assert_nothing_raised do
      assert_difference 'Event.count' do
        @valid_command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "Created repository \"#{@valid_command.object.name}\" in "\
      "institution \"#{@institution.name}\"", event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'execute method should fail if user attempts to create a repository in another institution' do
    @valid_command = CreateRepositoryCommand.new(institutions(:institution_two),
                                                 @valid_repository_params,
                                                 @user, @remote_ip)
    assert_raises RuntimeError do
      assert_difference 'Event.count' do
        @valid_command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "Attempted to create repository, but failed: Insufficient "\
    "privileges", event.description
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
    assert_equal "Attempted to create repository, but failed: Name can't be "\
    "blank",
                 event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  # object
  test 'object method should return the created Repository object' do
    assert_kind_of Repository, @valid_command.object
  end

end
