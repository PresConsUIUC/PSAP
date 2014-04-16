class UsersController < ApplicationController

  before_action :signed_in_user, except: [:new, :confirm, :create, :exists]
  before_action :before_new_user, only: [:new, :create]
  before_action :before_edit_user, only: [:edit, :update]
  before_action :before_show_user, only: :show
  before_action :admin_user, only: [:index, :destroy, :enable, :disable]

  helper_method :sort_column, :sort_direction

  def create
    command = CreateUserCommand.new(user_create_params, request.remote_ip)
    @user = command.object
    begin
      command.execute
      flash[:success] = 'Thanks for registering for PSAP! An email has been '\
        'sent to the address you provided. Follow the link in the email to '\
        'confirm your account.'
      redirect_to root_url
    rescue
      render 'new'
    end
  end

  # Mapped to GET /confirm
  def confirm
    user = User.find_by_username params[:username]
    raise ActiveRecord::RecordNotFound if !user

    command = ConfirmUserCommand.new(user, params[:code], request.remote_ip)
    begin
      command.execute
      flash[:success] = 'Your account has been confirmed. Please sign in.'
    rescue => e
      flash[:error] = "#{e}"
    ensure
      redirect_to signin_url
    end
  end

  def destroy
    user = User.find_by_username params[:username]
    raise ActiveRecord::RecordNotFound if !user

    command = DeleteUserCommand.new(user, current_user, request.remote_ip)
    begin
      command.execute
      flash[:success] = "User #{user.username} deleted."
    rescue => e
      flash[:error] = "#{e}"
    ensure
      redirect_to users_url
    end
  end

  def edit
  end

  # Responds to PATCH /users/:id/enable
  def enable
    user = User.find_by_username params[:username]
    raise ActiveRecord::RecordNotFound if !user

    command = EnableUserCommand.new(user, current_user, request.remote_ip)
    begin
      command.execute
      flash[:success] = "User #{user.username} enabled."
    rescue => e
      flash[:error] = "#{e}"
    ensure
      redirect_to :back
    end
  end

  # Responds to PATCH /users/:id/disable
  def disable
    user = User.find_by_username params[:username]
    raise ActiveRecord::RecordNotFound if !user

    command = DisableUserCommand.new(user, current_user, request.remote_ip)
    begin
      command.execute
      flash[:success] = "User #{user.username} disabled."
    rescue => e
      flash[:error] = "#{e}"
    ensure
      redirect_to :back
    end
  end

  # Responds to GET /users/:username/exists with either HTTP 200 or 404 for
  # the purpose of checking whether a user with the given username exists
  # from the registration form.
  def exists
    if User.find_by_username params[:username]
      render text: nil, status: 200
    else
      render text: nil, status: 404
    end
  end

  def index
    q = "%#{params[:q]}%"
    @users = User.joins(:institution).where(
          'users.username LIKE ? OR users.first_name LIKE ? OR users.last_name LIKE ?', q, q, q).
        order("#{sort_column} #{sort_direction}").
        paginate(page: params[:page], per_page: 50)
  end

  def new
    @user = User.new
  end

  def show
    @user = User.find_by_username params[:username]
    raise ActiveRecord::RecordNotFound if !@user
    @resources = @user.resources.order(:name) # TODO: pagination
  end

  def update
    @user = User.find_by_username params[:username]
    raise ActiveRecord::RecordNotFound if !@user

    was_unaffiliated = @user.institution.nil?

    # admin users can change usernames. Non-admins cannot.
    if !current_user.is_admin?
      params[:user].delete(:username)
    end

    command = UpdateUserCommand.new(@user, user_update_params, current_user,
                                    request.remote_ip)
    begin
      command.execute

      # If the user was not affiliated with an institution before the update,
      # but now is, this implies that they have just joined an institution for
      # the first time by following a link from their dashboard.
      if was_unaffiliated && @user.institution
        flash[:success] = @user == current_user ?
            "You are now a member of #{@user.institution.name}." :
            "#{@user.username} is now a member of #{@user.institution.name}."
      else
        flash[:success] = @user == current_user ?
            'Your profile has been updated.' :
            "#{@user.username}'s profile has been updated."
      end

      respond_to do |format|
        format.html {
          redirect_to was_unaffiliated && @user.institution ?
                          dashboard_url : edit_user_url(@user)
        }
        format.js { render 'edit' }
      end
    rescue
      render 'edit'
    end
  end

  private

  def before_edit_user
    # Normal users can only edit themselves. Administrators can edit anyone.
    @user = User.find_by_username params[:username]
    raise ActiveRecord::RecordNotFound if !@user
    redirect_to(root_url) unless current_user?(@user) || current_user.is_admin?
  end

  def before_new_user
    if signed_in?
      store_location
      redirect_to root_url, notice: 'You are already signed in.'
    end
  end

  def before_show_user
    # Normal users can only see other users from their own institution.
    # Administrators can see everyone.
    @user = User.find_by_username params[:username]
    raise ActiveRecord::RecordNotFound if !@user
    redirect_to(root_url) unless
        @user.institution == current_user.institution || current_user.is_admin?
  end

  def sort_column
    allowed_columns = User.column_names << 'institutions.name'
    allowed_columns.include?(params[:sort]) ? params[:sort] : 'last_name'
  end

  def user_create_params
    params.require(:user).permit(:username, :email, :first_name, :last_name,
                                 :password, :password_confirmation)
  end

  def user_update_params
    params.require(:user).permit(:username, :email, :first_name, :last_name,
                                 :password, :password_confirmation,
                                 :institution_id, :enabled,
                                 :show_contextual_help)
  end

end
