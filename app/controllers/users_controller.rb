class UsersController < ApplicationController

  before_action :signed_in_user, only: [:index, :edit, :update]
  before_action :correct_user,   only: [:edit, :update]

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = 'User account created.'
      redirect_to @user
    else
      render 'new'
    end
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
    if @user.update_attributes(user_params)
      flash[:success] = 'Profile updated.'
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :password,
                                 :password_confirmation)
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
