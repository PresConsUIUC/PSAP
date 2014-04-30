class ResourcesController < ApplicationController

  before_action :signed_in_user
  before_action :user_of_same_institution_or_admin, only: [:new, :create,
                                                           :edit, :update,
                                                           :show, :destroy]

  def create
    @location = Location.find(params[:location_id])
    command = CreateResourceCommand.new(@location, resource_params,
                                        current_user, request.remote_ip)
    @resource = command.object
    begin
      command.execute
      flash[:success] = "Resource \"#{@resource.name}\" created."
      redirect_to @resource
    rescue
      render 'new'
    end
  end

  def destroy
    @resource = Resource.find(params[:id])
    command = DeleteResourceCommand.new(@resource, current_user,
                                        request.remote_ip)
    begin
      command.execute
      flash[:success] = "Resource \"#{@resource.name}\" deleted."
      redirect_to @resource.location
    rescue
      redirect_to @resource.object
    end
  end

  def edit
    @resource = Resource.find(params[:id])
    @assessment_sections = Assessment.find_by_key('resource').
        assessment_sections.order(:index)
  end

  def new
    @location = Location.find(params[:location_id])
    @resource = @location.resources.build

    # New resources will get 1 of each dependent entity, to populate the form.
    # Additional ones may be created in JavaScript.
    @resource.creators.build
    @resource.extents.build
    @resource.resource_dates.build
    @resource.subjects.build

    @assessment_sections = Assessment.find_by_key('resource').
        assessment_sections.order(:index)
  end

  def show
    @resource = Resource.find(params[:id])
    @assessment_sections = Assessment.find_by_key('resource').
        assessment_sections.order(:index)

    respond_to do |format|
      format.html { @resource }
      format.xml {
        @institution = @resource.location.repository.institution
        @resource
      }
    end
  end

  def update
    @resource = Resource.find(params[:id])
    command = UpdateResourceCommand.new(@resource, resource_params,
                                        current_user, request.remote_ip)
    begin
      command.execute
      flash[:success] = "Resource \"#{@resource.name}\" updated."
      # redirect_to edit_resource_url(@resource)
      @assessment_sections = Assessment.find_by_key('resource').
          assessment_sections.order(:index)
      render 'edit'
    rescue
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
    redirect_to(root_url) unless
        location.repository.institution.users.include?(current_user) ||
            current_user.is_admin?
  end

  def resource_params
    params.require(:resource).permit(:description, :format, :local_identifier,
                                     :location, :name, :notes, :resource_type,
                                     :user_id,
                                     assessment_question_responses_attributes:
            [:assessment_question_option_id])
  end

end
