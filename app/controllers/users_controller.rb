class UsersController < ApplicationController

  before_action :correct_user, only: [:edit, :show, :update]
  before_action :admin_user, only: [:index, :destroy]

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

  def index
    @users = User.paginate(page: params[:page], per_page: 30)
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
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def user_create_params
    params.require(:user).permit(:username, :email, :first_name, :last_name,
                                 :password, :password_confirmation)
  end

  def user_update_params
    params.require(:user).permit(:email, :first_name, :last_name,
                                 :password, :password_confirmation)
  end

  def admin_user
    redirect_to(root_url) unless current_user.role.is_admin?
  end

  def signed_in_user
    unless signed_in?
      store_location
      redirect_to login_url, notice: 'Please sign in.'
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

end
