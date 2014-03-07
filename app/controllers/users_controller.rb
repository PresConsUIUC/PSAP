class UsersController < ApplicationController

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

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  private

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :password,
                                 :password_confirmation, :username)
  end

end
