class ChangePasswordCommand < Command

  def initialize(user, current_password, new_password, password_confirmation,
      doing_user, remote_ip)
    @user = user
    @current_password = current_password
    @new_password = new_password
    @password_confirmation = password_confirmation
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      raise 'Old and new passwords are the same' if
          @current_password == @new_password
      raise 'Insufficient privileges' unless
          @doing_user.is_admin? || @doing_user == @user
      raise 'Current password is incorrect' unless
          @user.authenticate(@current_password)

      @user.password = @new_password
      @user.password_confirmation = @password_confirmation
      @user.save!
    rescue ActiveRecord::RecordInvalid => e
      @user.events << Event.create(
          description: "Attempted to change the password for user "\
          "#{@user.username}, but failed: #{@user.errors.full_messages[0]}",
          user: @doing_user, address: @remote_ip,
          event_level: EventLevel::DEBUG)
      if @user == @doing_user
        raise "Failed to change your password: #{@user.errors.full_messages[0]}"
      else
        raise "Failed to change the password for user #{@user.username}: "\
      "#{@user.errors.full_messages[0]}"
      end
    rescue => e
      @user.events << Event.create(
          description: "Attempted to change the password for user "\
          "#{@user.username}, but failed: #{e.message}",
          user: @doing_user, address: @remote_ip,
          event_level: EventLevel::DEBUG)
      if @user == @doing_user
        raise "Failed to change your password: #{e.message}"
      else
        raise "Failed to change the password for user #{@user.username}: "\
      "#{e.message}"
      end
    else
      @user.events << Event.create(
          description: "Changed password for user #{@user.username}",
          user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @user
  end

end
