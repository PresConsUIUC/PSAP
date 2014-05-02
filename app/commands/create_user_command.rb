class CreateUserCommand < Command

  def initialize(user_params, remote_ip)
    @user_params = user_params
    @user = User.new(user_params)
    @remote_ip = remote_ip
  end

  def execute
    @user.role = Role.find_by_name 'User'
    begin
      if @user.save!
        UserMailer.welcome_email(@user).deliver
      end
    rescue ActiveRecord::RecordInvalid => e
      Event.create(description: "Failed to create account for user: "\
      "#{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE)
      raise e
    rescue => e
      Event.create(description: "Failed to create account for user: "\
      "#{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE,
                   event_level: EventLevel::ERROR)
      raise e
    else
      Event.create(description: "Created account for user #{@user.username}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::SUCCESS)
    end
  end

  def object
    @user
  end

end
