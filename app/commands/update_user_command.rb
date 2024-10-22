class UpdateUserCommand < Command

  def initialize(user, user_params, doing_user, remote_ip)
    @user = user
    @user_params = user_params
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      old_email = @user.email
      new_email = @user_params['email']

      # non-admin users are not allowed to update other users
      if !@doing_user.is_admin? && @doing_user != @user
        raise 'Insufficient privileges to update other users.'
      end

      # non-admin users are not allowed to change roles
      if !@doing_user.is_admin? && @user_params['role_id'].present? &&
          @user_params['role_id'].to_i != @user.role_id
        raise 'Insufficient privileges to change roles.'
      end

      # non-admin users are not allowed to change usernames (though they are
      # allowed to set them for the first time, in CreateUserCommand)
      if !@doing_user.is_admin? && @user.username &&
          @user_params['username'] && @user.username != @user_params['username']
        raise 'Insufficient privileges to change usernames.'
      end

      @user.update!(@user_params)
    rescue ActiveRecord::RecordInvalid
      if @user == @doing_user
        raise ValidationError,
              "Failed to update your account: "\
              "#{@user.errors.full_messages.first}"
      else
        raise ValidationError,
              "Failed to update user #{@user.username}: "\
              "#{@user.errors.full_messages.first}"
      end
    rescue => e
      if @user == @doing_user
        raise "Failed to update your account: #{e}"
      else
        raise "Failed to update user #{@user.username}: #{e}"
      end
    else
      # If the user is changing their email address, we should notify the
      # previous address, in case their account was hijacked.
      if new_email && old_email != new_email
        UserMailer.change_email(@user, old_email, new_email).deliver_now
      end
    end
  end

  def object
    @user
  end

end
