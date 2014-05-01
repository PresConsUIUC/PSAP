class DeleteUserCommand < Command

  def initialize(user, doing_user, remote_ip)
    @user = user
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @user.destroy!
      Event.create(description: "Deleted user #{@user.username}",
                   user: @doing_user, address: @remote_ip,
                   event_status: EventStatus::SUCCESS)
    rescue ActiveRecord::DeleteRestrictionError => e
      @user.errors.add(:base, e)
      raise e
    end
  end

  def object
    @user
  end

end
