class UsersController < ApplicationController

  before_action :signed_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :show, :update]
  before_action :admin_user, only: :destroy

  def create
    @user = User.new(user_create_params)
    if @user.save
      UserMailer.welcome_email(@user).deliver
      flash[:success] = 'You must confirm your account before you can log in.
                        An email containing a confirmation link has been sent.
                        Follow the link to confirm your account.'
      redirect_to root_url
    else
      render 'new'
    end
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

    # If the user has not yet confirmed their account, AND a confirmation_code
    # parameter is present in the URL query, confirm the user's account.
    if !@user.confirmed
      if params[:confirmation_code]
        if params[:confirmation_code] == @user.confirmation_code
          @user.confirmed = true
          @user.save!
          flash[:success] = 'Your account has been confirmed. Please log in.'
          redirect_to login_url
        else
          flash[:error] = 'Invalid confirmation code.'
          redirect_to root_url
        end
      end
    end
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
