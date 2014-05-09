class DeleteUserCommand < Command

  def initialize(user, doing_user, remote_ip)
    @user = user
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @user.destroy!
    rescue ActiveRecord::DeleteRestrictionError => e
      raise e # should never happen
    rescue => e
      Event.create(description: "Attempted to delete user #{@user.username}, "\
      "but failed: #{@user.errors.full_messages[0]}",
                   user: @doing_user, address: @remote_ip,
                   event_level: EventLevel::ERROR)
      raise "Failed to delete user #{@user.username}: "\
      "#{@user.errors.full_messages[0]}"
    else
      Event.create(description: "Deleted user #{@user.username}",
                   user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @user
  end

end
