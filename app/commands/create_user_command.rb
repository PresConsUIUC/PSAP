class CreateUserCommand < Command

  def initialize(user_params)
    @user_params = user_params
  end

  def execute
    @user = User.new(user_params)
    @user.role = Role.find_by_name 'User'
    if @user.save!
      UserMailer.welcome_email(@user).deliver
      Event.create(description: "Created account for user #{@user.username}",
                   user: @user)
    end
  end

  def object
    @user
  end

end
