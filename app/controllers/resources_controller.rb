class ResourcesController < ApplicationController

  before_action :signed_in_user
  before_action :user_of_same_institution_or_admin, only: [:new, :create,
                                                           :edit, :update,
                                                           :index, :show,
                                                           :destroy]

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
    location = resource.location
    name = resource.name
    resource.destroy
    flash[:success] = "#{name} deleted."
    redirect_to location
  end

  def edit
    @resource = Resource.find(params[:id])
  end

  def new
    @location = Location.find(params[:location_id])
    @resource = @location.resources.build

    # New resources will get 1 of each dependent entity. Additional ones may be
    # created in JavaScript.
    creator = @resource.creators.build
    extent = @resource.extents.build
    subject = @resource.subjects.build
  end

  def show
    @resource = Resource.find(params[:id])

    respond_to do |format|
      format.html { @resource }
      format.ead {
        @institution = @resource.location.repository.institution
        @resource
      }
    end
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

  def user_of_same_institution_or_admin
    # Normal users can only modify resources in their own institution.
    # Administrators can edit any resource.
    if params[:id]
      resource = Resource.find(params[:id])
      location = resource.location
    else
      location = Location.find(params[:location_id])
    end
    redirect_to(resources_url) unless
        location.repository.institution.users.include?(current_user) ||
            current_user.is_admin?
  end

  def resource_params
    params.require(:resource).permit(:name, :location, :resource_type)
  end

end
