class CreateUserCommand < Command

  def initialize(user_params, remote_ip)
    @user_params = user_params
    @user = User.new(user_params)
    @remote_ip = remote_ip
  end

  def execute
    begin
      role = Role.find_by_name 'User'
      raise 'Missing "User" role.' unless role
      @user.role = role

      UserMailer.welcome_email(@user).deliver if @user.save!
    rescue ActiveRecord::RecordInvalid => e
      Event.create(description: "Attempted to create a user account, but "\
      "failed: #{@user.errors.full_messages[0]}",
                   user: nil, address: @remote_ip,
                   event_level: EventLevel::DEBUG)
      raise "Failed to create user account: #{@user.errors.full_messages[0]}"
    rescue => e
      Event.create(description: "Attempted to create a user account, but "\
      "failed: #{e.message}",
                   user: nil, address: @remote_ip,
                   event_level: EventLevel::ERROR)
      raise "Failed to create user account: #{e.message}"
    else
      Event.create(description: "Created account for user #{@user.username}",
                   user: @user, address: @remote_ip)
    end
  end

  def object
    @user
  end

end
