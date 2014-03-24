class UsersController < ApplicationController

  before_action :signed_in_user, except: [:new, :create]
  before_action :before_new_user, only: [:new, :create]
  before_action :before_edit_user, only: [:edit, :update]
  before_action :before_show_user, only: :show
  before_action :admin_user, only: [:index, :destroy, :enable, :disable]

  def create
    @user = User.new(user_create_params)

    # If the user has specified a new institution, create it and associate the
    # user with it
    if !@user.institution
      institution = @user.institution.new
      institution.name = params[:institution]
      institution.save!
    end

    if @user.save
      UserMailer.welcome_email(@user).deliver
      redirect_to action: 'confirm'
    else
      render 'new'
    end
  end

  # Mapped to GET /confirm
  def confirm
    # If the user has supplied username and confirmation_code parameters,
    # check that they are correct and activate the user if so. Otherwise,
    # silently redirect to the root URL.
    @user = User.find_by_username params[:username]
    if @user && !@user.confirmed &&
        params[:confirmation_code] == @user.confirmation_code
      @user.confirmed = true
      @user.enabled = true
      @user.save!
      flash[:success] = 'Your account has been confirmed. Please log in.'
      redirect_to login_url
    end
    redirect_to root_url
  end

  def destroy
    user = User.find(params[:id])
    name = user.full_name
    user.destroy
    flash[:success] = "#{name} deleted."
    redirect_to users_url
  end

  def edit
  end

  # Responds to PATCH /users/:id/enable
  def enable
    user = User.find(params[:id])
    user.enabled = true
    user.save!
    flash[:success] = "User #{user.username} enabled."
    redirect_to users_url
  end

  # Responds to PATCH /users/:id/disable
  def disable
    user = User.find(params[:id])
    user.enabled = false
    user.save!
    flash[:success] = "User #{user.username} disabled."
    redirect_to users_url
  end

  def index
    @users = User.order(:username).paginate(page: params[:page], per_page: 30)
  end

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def update
    if @user.update_attributes(user_update_params)
      flash[:success] = 'Profile updated.'
      redirect_to edit_user_url(@user)
    else
      render 'edit'
    end
  end

  private

  def before_edit_user
    # Normal users can only edit themselves. Administrators can edit anyone.
    @user = User.find(params[:id])
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
    @user = User.find(params[:id])
    redirect_to(root_url) unless
        @user.institution == current_user.institution || current_user.is_admin?
  end

  def user_create_params
    params.require(:user).permit(:username, :email, :first_name, :last_name,
                                 :password, :password_confirmation, :institution)
  end

  def user_update_params
    params.require(:user).permit(:email, :first_name, :last_name,
                                 :password, :password_confirmation, :institution,
                                 :enabled, :time_zone)
  end

end
