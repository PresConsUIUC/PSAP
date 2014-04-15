class DeleteUserCommand < Command

  def initialize(user, doing_user)
    @user = user
    @doing_user = doing_user
  end

  def execute
    begin
      @user.destroy!
      Event.create(description: "Deleted user #{@user.username}",
                   user: @doing_user)
    rescue ActiveRecord::DeleteRestrictionError => e
      @user.errors.add(:base, e)
      raise e
    end
  end

  def object
    @user
  end

end
