class CreateUserCommand < Command

  def initialize(user_params, remote_ip, send_email = true)
    @user_params = user_params
    @user = User.new(user_params)
    @remote_ip = remote_ip
    @send_email = send_email
  end

  def execute
    begin
      role = Role.find_by_name 'User'
      raise 'Missing "User" role.' unless role
      @user.role = role
      ActiveRecord::Base.transaction do
        @user.save!
        UserMailer.confirm_account_email(@user).deliver if @send_email
      end
    rescue ActiveRecord::RecordInvalid
      @user.events << Event.create(
          description: "Attempted to create a user account, but "\
          "failed: #{@user.errors.full_messages.first}",
          user: nil, address: @remote_ip, event_level: EventLevel::DEBUG)
      raise ValidationError,
            "Failed to create user account: #{@user.errors.full_messages.first}"
    rescue => e
      @user.events << Event.create(
          description: "Attempted to create a user account, but "\
          "failed: #{e.message}",
          user: nil, address: @remote_ip,
          event_level: EventLevel::ERROR)
      raise "Failed to create user account: #{e.message}"
    else
      @user.events << Event.create(
          description: "Created account for user #{@user.username}",
          user: @user, address: @remote_ip)
    end
  end

  def object
    @user
  end

end
