class EnableUserCommand < Command

  def initialize(user, doing_user)
    @user = user
    @doing_user = doing_user
  end

  def execute
    @user.enabled = true
    @user.save!

    Event.create(description: "Enabled user #{@user.username}",
                 user: @doing_user)
  end

  def object
    @user
  end

end
