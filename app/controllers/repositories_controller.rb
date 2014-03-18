class RepositoriesController < ApplicationController

  before_action :signed_in_user
  before_action :user_of_same_institution_or_admin, only: [:new, :create,
                                                           :edit, :update,
                                                           :index, :show,
                                                           :destroy]

  def create
    @repository = Repository.new(repository_params)
    @repository.institution = current_user.institution
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
    @repository.institution = @user.institution
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

  def user_of_same_institution_or_admin
    # Normal users can only modify repositories in their own institution.
    # Administrators can edit any repository.
    if params[:id]
      repository = Repository.find(params[:id])
      institution = repository.institution
    else
      institution = Institution.find(params[:institution_id])
    end
    redirect_to(repositories_url) unless
        institution.users.include?(current_user) || current_user.is_admin?
  end

  def repository_params
    params.require(:repository).permit(:name, :institution)
  end

end
