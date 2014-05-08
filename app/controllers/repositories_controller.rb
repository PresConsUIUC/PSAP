class RepositoriesController < ApplicationController

  before_action :signed_in_user
  before_action :user_of_same_institution_or_admin, only: [:new, :create,
                                                           :edit, :update,
                                                           :show, :destroy]

  def create
    @institution = Institution.find(params[:institution_id])
    command = CreateRepositoryCommand.new(@institution, repository_params,
        current_user, request.remote_ip)
    @repository = command.object
    begin
      command.execute
    rescue => e
      flash[:error] = "#{e}"
      render 'new'
    else
      flash[:success] = "Repository \"#{@repository.name}\" created."
      redirect_to @repository
    end
  end

  def destroy
    repository = Repository.find(params[:id])
    command = DeleteRepositoryCommand.new(repository,
                                          current_user, request.remote_ip)
    begin
      command.execute
    rescue => e
      flash[:error] = "#{e}"
      redirect_to repository
    else
      flash[:success] = "Repository \"#{repository.name}\" deleted."
      redirect_to repository.institution
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
    @locations = @repository.locations.order(:name).
        paginate(page: params[:page],
                 per_page: Psap::Application.config.results_per_page)
  end

  def update
    @repository = Repository.find(params[:id])
    command = UpdateRepositoryCommand.new(@repository, repository_params,
                                          current_user, request.remote_ip)
    begin
      command.execute
    rescue
      render 'edit'
    else
      flash[:success] = "Repository \"#{@repository.name}\" updated."
      redirect_to @repository
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
