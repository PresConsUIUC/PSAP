require 'test_helper'

class UpdateUserCommandTest < ActiveSupport::TestCase

  def setup
    @user = users(:normal_user)
    @valid_params = users(:normal_user).attributes
    @valid_params.delete('id')
    @valid_params['username'] = 'asdfjkjhasfd'
    @doing_user = users(:normal_user)
    @remote_ip = '10.0.0.1'
    @valid_command = UpdateUserCommand.new(@user, @valid_params,
                                           @doing_user, @remote_ip)

    @invalid_params = @valid_params.dup
    @invalid_params['username'] = ''
    @invalid_command = UpdateUserCommand.new(@user, @invalid_params,
                                             @doing_user, @remote_ip)
  end

  # execute
  test 'execute method should save user if valid' do
    assert_nothing_raised do
      assert_difference 'Event.count' do
        @valid_command.execute
      end
    end
    assert !@valid_command.object.changed?
    event = Event.order(:created_at).last
    assert_equal "Updated user #{@valid_command.object.username}",
                 event.description
    assert_equal @doing_user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'non-admin users should not be allowed to update other users' do
    @user = users(:disabled_user)
    @valid_params = users(:disabled_user).attributes
    @valid_params.delete('id')
    @valid_params['username'] = 'asdfjkjhasfd'
    @doing_user = users(:normal_user)
    @remote_ip = '10.0.0.1'
    @valid_command = UpdateUserCommand.new(@user, @valid_params,
                                           @doing_user, @remote_ip)
    e = assert_raises RuntimeError do
      @valid_command.execute
      assert_equal 'Insufficient privileges', e.message
    end
  end

  test 'non-admin users should not be able to change usernames once set' do
    @user = users(:normal_user)
    @valid_params = { username: 'dfasdfsaf' }
    @doing_user = users(:normal_user)
    @remote_ip = '10.0.0.1'
    @valid_command = UpdateUserCommand.new(@user, @valid_params,
                                           @doing_user, @remote_ip)
    e = assert_raises RuntimeError do
      @valid_command.execute
      assert_equal 'Insufficient privileges', e.message
    end
  end

  test 'non-admin users should not be able to change roles' do
    @user = users(:normal_user)
    @valid_params = { role_id: roles(:admin_role).id }
    @doing_user = users(:normal_user)
    @remote_ip = '10.0.0.1'
    @valid_command = UpdateUserCommand.new(@user, @valid_params,
                                           @doing_user, @remote_ip)
    e = assert_raises RuntimeError do
      @valid_command.execute
      assert_equal 'Insufficient privileges', e.message
    end
  end

  test 'execute method should fail if validation failed' do
    assert_raises ValidationError do
      assert_difference 'Event.count' do
        @invalid_command.execute
      end
    end
  end

  test 'execute method failure message should be tailored to the doing user' do
    # user updating self
    e = assert_raises ValidationError do
      @invalid_command.execute
      assert_equal "Failed to update your account: ", e.message
    end

    # user updating other user
    e = assert_raises ValidationError do
      @invalid_command.execute
      assert_equal "Failed to update user #{@user.username}: ", e.message
    end

    event = Event.order(:created_at).last
    assert_equal "Attempted to update user #{@user.username}, "\
      "but failed: Username can't be blank",
                 event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'should notify previous email if user is changing their email' do
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      @valid_command.execute
    end
    email = ActionMailer::Base.deliveries.last
    assert_equal 'Your PSAP email has changed', email.subject
    assert_equal users(:normal_user).email, email.to[0]
  end

  # object
  test 'object method should return the User object' do
    assert_kind_of User, @valid_command.object
  end

end
