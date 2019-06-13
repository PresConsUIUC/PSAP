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
        UserMailer.confirm_account_email(@user).deliver_now if @send_email
      end
    rescue ActiveRecord::RecordInvalid
      raise ValidationError,
            "Failed to create user account: #{@user.errors.full_messages.first}"
    rescue => e
      raise "Failed to create user account: #{e.message}"
    end
  end

  def object
    @user
  end

end
