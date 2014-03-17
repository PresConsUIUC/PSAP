class LocationsController < ApplicationController

  before_action :signed_in_user

  def create
    @repository = Repository.find(params[:repository_id])
    @location = @repository.locations.build(location_params)
    if @location.save
      flash[:success] = 'Location created.'
      redirect_to @location
    else
      render 'new'
    end
  end

  def destroy
    location = Location.find(params[:id])
    name = location.name
    location.destroy
    flash[:success] = "#{name} deleted."
    redirect_to locations_url
  end

  def edit
    @location = Location.find(params[:id])
  end

  def index
    @repository = Repository.find(params[:repository_id])
    @locations = @repository.locations.paginate(page: params[:page],
                                                per_page: 30)
  end

  def new
    @repository = Repository.find(params[:repository_id])
    @location = @repository.locations.build
  end

  def show
    @location = Location.find(params[:id])
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

  def location_params
    params.require(:location).permit(:name, :repository)
  end

end
