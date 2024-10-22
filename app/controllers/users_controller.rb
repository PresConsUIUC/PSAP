class UsersController < ApplicationController

  before_action :signed_in_user, except: [:new, :confirm, :create, :exists]
  before_action :before_new_user, only: [:new, :create]
  before_action :before_edit_user, only: [:edit, :update]
  before_action :before_show_user, only: :show
  before_action :admin_user, only: [:approve_institution, :index, :destroy,
                                    :enable, :disable]

  helper_method :sort_column, :sort_direction

  ##
  # Counterpart of refuse_institution.
  # Responds to PATCH /users/:username/approve-institution
  #
  def approve_institution
    user = User.find_by_username(params[:username])
    raise ActiveRecord::RecordNotFound unless user

    command = ApproveUserInstitutionCommand.new(user, current_user,
                                                request.remote_ip)
    begin
      command.execute
    rescue => e
      flash['error'] = "#{e}"
    else
      flash['success'] = "Institution change approved for user #{user.username}."
    ensure
      redirect_back fallback_location: user_url(user)
    end
  end

  def create
    command = CreateUserCommand.new(user_create_params, request.remote_ip)
    @user = command.object
    begin
      unless verify_recaptcha(model: @user, message: 'The data you entered '\
          'for the CAPTCHA wasn\'t correct. Please try again.')
        raise ValidationError
      end
      command.execute
    rescue ValidationError
      render 'new'
    rescue => e
      flash['error'] = "#{e}"
      render 'new'
    else
      render 'registration_success'
    end
  end

  ##
  # Responds to GET /confirm; linked to from the welcome email that users
  # receive after creating their account.
  #
  def confirm
    user = User.find_by_username params[:username]
    raise ActiveRecord::RecordNotFound unless user

    command = ConfirmUserCommand.new(user, params[:code], request.remote_ip)
    begin
      command.execute
    rescue => e
      flash['error'] = "#{e}"
      redirect_to signin_url
    else
      render 'confirmed'
    end
  end

  def destroy
    user = User.find_by_username params[:username]
    raise ActiveRecord::RecordNotFound unless user

    _current_user = current_user
    command = DeleteUserCommand.new(user, _current_user, request.remote_ip)
    begin
      command.execute
    rescue => e
      flash['error'] = "#{e}"
      redirect_to users_url
    else
      if user == _current_user
        flash['success'] = 'Your account has been deleted.'
        command = SignOutCommand.new(user, request.remote_ip)
        command.execute
        sign_out
        redirect_to root_url
      else
        flash['success'] = "User #{user.username} deleted."
        redirect_to users_url
      end
    end
  end

  def edit
    @roles = Role.all.order(:name)
    @user_role = Role.find_by_name('User')

    # Gather institutions for the institution select menu.
    set_institutions_ivar
  end

  ##
  # Responds to PATCH /users/:id/enable
  #
  def enable
    user = User.find_by_username params[:username]
    raise ActiveRecord::RecordNotFound unless user

    command = EnableUserCommand.new(user, current_user, request.remote_ip)
    begin
      command.execute
    rescue => e
      flash['error'] = "#{e}"
    else
      flash['success'] = "User #{user.username} enabled."
    ensure
      redirect_back fallback_location: user_url(user)
    end
  end

  ##
  # Responds to PATCH /users/:id/disable
  #
  def disable
    user = User.find_by_username params[:username]
    raise ActiveRecord::RecordNotFound unless user

    command = DisableUserCommand.new(user, current_user, request.remote_ip)
    begin
      command.execute
    rescue => e
      flash['error'] = "#{e}"
    else
      flash['success'] = "User #{user.username} disabled."
    ensure
      redirect_back fallback_location: user_url(user)
    end
  end

  ##
  # Responds to GET /users/:username/exists with either HTTP 200 or 404 for
  # the purpose of checking whether a user with the given username exists
  # from the registration form. (Can't do GET /users/:username because it
  # requires being signed in.)
  #
  def exists
    render plain: nil,
           status: User.find_by_username(params[:username]) ? 200: 404
  end

  def index
    q = "%#{params[:q]}%"
    @users = User.
        joins('LEFT JOIN institutions ON users.institution_id = institutions.id').
        where('LOWER(users.username) LIKE ? OR LOWER(users.first_name) LIKE ? OR LOWER(users.last_name) LIKE ?',
              q.downcase, q.downcase, q.downcase).
        order("#{sort_column} #{sort_direction}").
        paginate(page: params[:page],
                 per_page: ::Configuration.instance.results_per_page)
    @emailable_addresses = User.where(confirmed: true).map(&:email)
  end

  def new
    @user = User.new
  end

  ##
  # Counterpart of approve_institution.
  # Responds to PATCH /users/:username/refuse-institution
  #
  def refuse_institution
    user = User.find_by_username(params[:username])
    raise ActiveRecord::RecordNotFound unless user

    command = RefuseUserInstitutionCommand.new(user, current_user,
                                               request.remote_ip)
    begin
      command.execute
    rescue => e
      flash['error'] = "#{e}"
    else
      flash['success'] = "Institution change refused for user #{user.username}."
    ensure
      redirect_back fallback_location: user_url(user)
    end
  end

  ##
  # Responds to PATCH /users/:id/send-confirmation-email
  #
  def send_confirmation_email
    user = User.find_by_username params[:username]
    raise ActiveRecord::RecordNotFound unless user

    command = SendConfirmationEmailCommand.new(user, current_user,
                                               request.remote_ip)
    begin
      command.execute
    rescue => e
      flash['error'] = "#{e}"
    else
      flash['success'] = 'Confirmation email sent.'
    ensure
      redirect_back fallback_location: user_url(user)
    end
  end

  def show
    @user = User.find_by_username params[:username]
    raise ActiveRecord::RecordNotFound unless @user

    @resources = @user.resources.paginate(page: params[:page],
                 per_page: ::Configuration.instance.results_per_page)
  end

  ##
  # This action is meant to be invoked via ajax.
  #
  def update
    @user = User.find_by_username params[:username]
    raise ActiveRecord::RecordNotFound unless @user
    @user_role = Role.find_by_name('User')
    @roles = Role.all.order(:name)

    if params[:user][:current_password] # the user is changing their password
      command = ChangePasswordCommand.new(
          @user, params[:user][:current_password],
          params[:user][:password],
          params[:user][:password_confirmation],
          current_user,
          request.remote_ip)
      begin
        command.execute
      rescue ValidationError
        render 'edit'
      rescue => e
        flash['error'] = "#{e}"
        render 'edit'
      else
        flash['success'] = @user == current_user ?
            'Your password has been changed.' :
            "#{@user.username}'s password has been changed."
        keep_flash
        redirect_to edit_user_url(@user)
      end
    elsif params[:user][:desired_institution_id] # the user is changing their institution
      new_institution = Institution.find(params[:user][:desired_institution_id])
      command = JoinInstitutionCommand.new(@user, new_institution,
                                           current_user, request.remote_ip)
      begin
        command.execute
      rescue ValidationError
        render 'edit'
      rescue => e
        flash['error'] = "#{e}"
        render 'edit'
      else
        if @user.institution == new_institution # already joined, which means an admin did it
          flash['success'] = "#{@user.username} is already a member of "\
          "#{new_institution.name}."
        else
          flash['success'] = "An administrator has been notified and will "\
          "review your request to join #{new_institution.name} momentarily,"
        end
        keep_flash
        redirect_to dashboard_path
      end
    else # the user is changing their basic info
      command = UpdateUserCommand.new(@user, user_update_params, current_user,
                                      request.remote_ip)
      begin
        command.execute
      rescue ValidationError
        # Gather institutions for the institution select menu.
        set_institutions_ivar
        render 'edit'
      rescue => e
        flash['error'] = "#{e}"

        # Gather institutions for the institution select menu.
        set_institutions_ivar
        render 'edit'
      else
        flash['success'] = @user == current_user ?
            'Your profile has been updated.' :
            "#{@user.username}'s profile has been updated."
        keep_flash
        redirect_to edit_user_url(@user)
      end
    end
  end

  private

  def before_edit_user
    # Normal users can only edit themselves. Administrators can edit anyone.
    @user = User.find_by_username params[:username]
    raise ActiveRecord::RecordNotFound unless @user
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
    raise ActiveRecord::RecordNotFound unless @user
    redirect_to(root_url) unless
        @user.institution == current_user.institution || current_user.is_admin?
  end

  def set_institutions_ivar
    # Put the test institution at the top per GitHub issue #336.
    test_institution = Institution.find_by_name('Test Institution')
    if test_institution
      @institutions = Institution.where('id != ?', test_institution.id).order(:name).to_a
      @institutions.unshift(test_institution)
    else
      @institutions = Institution.all.order(:name).to_a
    end
  end

  def sort_column
    allowed_columns = User.column_names + ['institutions.country',
                                           'institutions.name']
    allowed_columns.include?(params[:sort]) ? params[:sort] : 'last_name'
  end

  def user_create_params
    params.require(:user).permit(:about, :username, :email, :first_name,
                                 :last_name, :password, :password_confirmation)
  end

  def user_update_params
    params.require(:user).permit(:about, :desired_institution_id, :enabled,
                                 :email, :first_name, :last_name, :role_id,
                                 :username)
  end

end
