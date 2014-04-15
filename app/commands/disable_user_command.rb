class DisableUserCommand < Command

  def initialize(user, doing_user)
    @user = user
    @doing_user = doing_user
  end

  def execute
    @user.enabled = false
    @user.save!

    Event.create(description: "Disabled user #{@user.username}",
                 user: @doing_user)
  end

  def object
    @user
  end

end
