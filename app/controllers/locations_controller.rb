class LocationsController < ApplicationController

  before_action :signed_in_user
  before_action :user_of_same_institution_or_admin, only: [:new, :create,
                                                           :edit, :update,
                                                           :index, :show,
                                                           :destroy]

  def create
    @repository = Repository.find(params[:repository_id])
    @location = @repository.locations.build(location_params)
    if @location.save
      flash[:success] = "Location \"#{@location.name}\" created."
      redirect_to @location
    else
      render 'new'
    end
  end

  def destroy
    location = Location.find(params[:id])
    repository = location.repository
    name = location.name
    location.destroy
    flash[:success] = "Location \"#{name}\" deleted."
    redirect_to repository
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
    if @location.update_attributes(location_params)
      flash[:success] = 'Location updated.'
      redirect_to @location
    else
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
