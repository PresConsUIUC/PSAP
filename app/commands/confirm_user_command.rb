class ConfirmUserCommand < Command

  def initialize(user, confirmation_code)
    @user = user
    @confirmation_code = confirmation_code
  end

  def execute
    if @user && !@user.confirmed && @confirmation_code == @user.confirmation_code
      @user.confirmed = true
      @user.confirmation_code = nil
      @user.enabled = true
      @user.save!

      Event.create(description: "Confirmed user #{@user.username}",
                   user: @user)
    end
  end

  def object
    @user
  end

end
