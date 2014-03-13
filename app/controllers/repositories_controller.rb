class RepositoriesController < ApplicationController

  before_action :signed_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def create
    @repository = Repository.new(repository_params)
    if @repository.save
      flash[:success] = 'Repository created.'
      redirect_to @repository
    else
      render 'new'
    end
  end

  def destroy
    repository = Repository.find(params[:id])
    name = repository.full_name
    repository.destroy
    flash[:success] = "#{name} deleted."
    redirect_to repositories_url
  end

  def edit
    @repository = Repository.find(params[:id])
  end

  def index
    @repositories = Repository.paginate(page: params[:page], per_page: 30)
  end

  def new
    @repository = Repository.new
  end

  def show
    @repository = Repository.find(params[:id])
  end

  def update
    @repository = Repository.find(params[:id])
    if @repository.update_attributes(user_params)
      flash[:success] = 'Repository updated.'
      redirect_to @repository
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:repository).permit(:name)
  end

end
