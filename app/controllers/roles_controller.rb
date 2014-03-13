class RolesController < ApplicationController

  before_action :signed_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def create
    @role = Role.new(role_params)
    if @role.save
      flash[:success] = 'Role created.'
      redirect_to @role
    else
      render 'new'
    end
  end

  def destroy
    role = Role.find(params[:id])
    name = role.name
    role.destroy
    flash[:success] = "#{name} deleted."
    redirect_to roles_url
  end

  def edit
    @role = Role.find(params[:id])
  end

  def index
    @roles = Role.paginate(page: params[:page], per_page: 30)
  end

  def new
    @role = Role.new
  end

  def show
    @role = Role.find(params[:id])
  end

  def update
    if @role.update_attributes(role_params)
      flash[:success] = 'Role updated.'
      redirect_to @role
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:key, :name)
  end

end
