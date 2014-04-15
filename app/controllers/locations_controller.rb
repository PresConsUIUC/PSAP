class LocationsController < ApplicationController

  before_action :signed_in_user
  before_action :user_of_same_institution_or_admin, only: [:new, :create,
                                                           :edit, :update,
                                                           :show, :destroy]

  def create
    command = CreateLocationCommand.new(
        Repository.find(params[:repository_id]),
        location_params,
        current_user)
    begin
      command.execute
      flash[:success] = "Location \"#{command.object.name}\" created."
      redirect_to command.object
    rescue
      render 'new'
    end
  end

  def destroy
    command = DeleteLocationCommand.new(
        Location.find(params[:id]),
        current_user)
    begin
      command.execute
      flash[:success] = "Location \"#{command.object.name}\" deleted."
      redirect_to command.object.repository
    rescue
      redirect_to command.object
    end
  end

  def edit
    @location = Location.find(params[:id])
  end

  def new
    @repository = Repository.find(params[:repository_id])
    @location = @repository.locations.build
  end

  def show
    @location = Location.find(params[:id])
    # show only top-level resources
    @resources = @location.resources.where(parent_id: nil).order(:name) # TODO: pagination
  end

  def update
    @location = Location.find(params[:id])
    command = UpdateLocationCommand.new(@location, location_params,
                                        current_user)
    begin
      command.execute
      flash[:success] = "Location \"#{@location.name}\" updated."
      redirect_to @location
    rescue
      render 'edit'
    end
  end

  private

  def user_of_same_institution_or_admin
    # Normal users can only modify locations in their own institution.
    # Administrators can edit any location.
    if params[:id]
      location = Location.find(params[:id])
      repository = location.repository
    else
      repository = Repository.find(params[:repository_id])
    end
    redirect_to(root_url) unless
        repository.institution.users.include?(current_user) ||
            current_user.is_admin?
  end

  def location_params
    params.require(:location).permit(:name, :repository)
  end

end
