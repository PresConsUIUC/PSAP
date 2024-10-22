class RepositoriesController < ApplicationController

  before_action :signed_in_user
  before_action :user_of_same_institution_or_admin,
                only: [:create, :destroy, :edit, :new, :show, :update]

  def create
    @institution = Institution.find(params[:institution_id])
    command = CreateRepositoryCommand.new(@institution, repository_params,
        current_user, request.remote_ip)
    @repository = command.object
    begin
      command.execute
    rescue ValidationError
      response.headers['X-Psap-Result'] = 'error'
      render partial: 'shared/validation_messages',
             locals: { entity: @repository }
    rescue => e
      response.headers['X-Psap-Result'] = 'error'
      flash['error'] = "#{e}"
      keep_flash
      render 'create'
    else
      response.headers['X-Psap-Result'] = 'success'
      flash['success'] = "Repository \"#{@repository.name}\" created."
      keep_flash
      render 'create'
    end
  end

  def destroy
    repository = Repository.find(params[:id])
    command = DeleteRepositoryCommand.new(repository,
                                          current_user, request.remote_ip)
    begin
      command.execute
    rescue => e
      flash['error'] = "#{e}"
      redirect_to repository
    else
      flash['success'] = "Repository \"#{repository.name}\" deleted."
      redirect_to repository.institution
    end
  end

  def edit
    if request.xhr?
      @repository = Repository.find(params[:id])
      render partial: 'edit_form', locals: { action: :edit }
    else
      render status: 406, plain: 'Not Acceptable'
    end
  end

  def new
    if request.xhr?
      @institution = Institution.find(params[:institution_id])
      @repository = @institution.repositories.build
      render partial: 'edit_form', locals: { action: :create }
    else
      render status: 406, plain: 'Not Acceptable'
    end
  end

  def show
    prepare_show_view
  end

  def update
    @repository = Repository.find(params[:id])
    command = UpdateRepositoryCommand.new(@repository, repository_params,
                                          current_user, request.remote_ip)
    begin
      command.execute
    rescue ValidationError
      response.headers['X-Psap-Result'] = 'error'
      render partial: 'shared/validation_messages',
             locals: { entity: @repository }
    rescue => e
      response.headers['X-Psap-Result'] = 'error'
      flash['error'] = "#{e}"
      render 'show'
    else
      prepare_show_view
      response.headers['X-Psap-Result'] = 'success'
      flash['success'] = "Repository \"#{@repository.name}\" updated."
      render 'show'
    end
  end

  private

  def prepare_show_view
    @repository = Repository.find(params[:id])
    @locations = @repository.locations.order(:name).
        paginate(page: params[:page],
                 per_page: ::Configuration.instance.results_per_page)
  end

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
