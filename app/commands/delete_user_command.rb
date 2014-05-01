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
      Event.create(description: "Failed to delete user #{@user.username}: "\
      "#{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE)
      @user.errors.add(:base, e)
      raise e
    rescue => e
      Event.create(description: "Failed to delete user #{@user.username}: "\
      "#{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE)
      raise e
    else
      Event.create(description: "Deleted user #{@user.username}",
                   user: @doing_user, address: @remote_ip,
                   event_status: EventStatus::SUCCESS)
    end
  end

  def object
    @user
  end

end
