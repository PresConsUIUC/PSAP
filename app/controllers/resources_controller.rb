class ResourcesController < ApplicationController

  before_action :signed_in_user

  def create
    @location = Location.find(params[:location_id])
    @resource = @location.resources.build(resource_params)
    if @resource.save
      flash[:success] = 'Resource created.'
      redirect_to @resource
    else
      render 'new'
    end
  end

  def destroy
    resource = Resource.find(params[:id])
    name = resource.name
    resource.destroy
    flash[:success] = "#{name} deleted."
    redirect_to resources_url
  end

  def edit
    @resource = Resource.find(params[:id])
  end

  def index
    @location = Location.find(params[:location_id]) if params[:location_id]
    @resources = Resource.paginate(page: params[:page], per_page: 30)
  end

  def new
    @location = Location.find(params[:location_id])
    @resource = @location.resources.build
  end

  def show
    @resource = Resource.find(params[:id])
  end

  def update
    @resource = Resource.find(params[:id])
    if @resource.update_attributes(resource_params)
      flash[:success] = 'Resource updated.'
      redirect_to @resource
    else
      render 'edit'
    end
  end

  private

  def resource_params
    params.require(:resource).permit(:name, :type)
  end

end
