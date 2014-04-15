class RepositoriesController < ApplicationController

  before_action :signed_in_user
  before_action :user_of_same_institution_or_admin, only: [:new, :create,
                                                           :edit, :update,
                                                           :show, :destroy]

  def create
    @institution = Institution.find(params[:institution_id])
    command = CreateRepositoryCommand.new(@institution, repository_params,
        current_user)
    @repository = command.object
    begin
      command.execute
      flash[:success] = "Repository \"#{@repository.name}\" created."
      redirect_to @repository
    rescue
      render 'new'
    end
  end

  def destroy
    command = DeleteRepositoryCommand.new(
        Repository.find(params[:id]),
        current_user)
    begin
      command.execute
      flash[:success] = "Repository \"#{command.object.name}\" deleted."
      redirect_to command.object.institution
    rescue
      redirect_to command.object
    end
  end

  def edit
    @repository = Repository.find(params[:id])
  end

  def new
    @institution = Institution.find(params[:institution_id])
    @repository = @institution.repositories.build
  end

  def show
    @repository = Repository.find(params[:id])
  end

  def update
    @repository = Repository.find(params[:id])
    command = UpdateRepositoryCommand.new(@repository, repository_params,
                                          current_user)
    begin
      command.execute
      flash[:success] = "Repository \"#{@repository.name}\" updated."
      redirect_to @repository
    rescue
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
    redirect_to(root_url) unless
        institution.users.include?(current_user) || current_user.is_admin?
  end

  def repository_params
    params.require(:repository).permit(:name, :institution)
  end

end
