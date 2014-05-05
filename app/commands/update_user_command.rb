class UpdateUserCommand < Command

  def initialize(user, user_params, doing_user, remote_ip)
    @user = user
    @user_params = user_params
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      # If the user is changing their email address, we need to notify the
      # previous address, in case their account was hijacked.
      old_email = @user.email
      new_email = @user_params[:email]
      if old_email != new_email
        UserMailer.change_email(@user, old_email, new_email).deliver
      end

      @user.update!(@user_params)
    rescue ActiveRecord::RecordInvalid => e
      Event.create(description: "Failed to update user "\
      "\"#{@user.username}\": #{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE,
                   event_level: EventLevel::DEBUG)
      raise e
    rescue => e
      Event.create(description: "Failed to update user "\
      "\"#{@user.username}\": #{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE,
                   event_level: EventLevel::ERROR)
      raise e
    else
      Event.create(description: "Updated user #{@user.username}",
                   user: @doing_user, address: @remote_ip,
                   event_status: EventStatus::SUCCESS)
    end
  end

  def object
    @user
  end

end
