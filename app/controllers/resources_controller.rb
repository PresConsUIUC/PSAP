class ResourcesController < ApplicationController

  before_action :signed_in_user
  before_action :user_of_same_institution_or_admin,
                only: [:new, :create, :edit, :import, :names, :update, :show,
                       :destroy]

  def create
    @location = Location.find(params[:location_id])
    command = CreateResourceCommand.new(@location, resource_params,
                                        current_user, request.remote_ip)
    @resource = command.object
    @assessment_sections = Assessment.find_by_key('resource').
        assessment_sections.order(:index)
    begin
      command.execute
    rescue ValidationError
      render 'new'
    rescue => e
      flash[:error] = "#{e}"
      render 'new'
    else
      flash[:success] = "Resource \"#{@resource.name}\" created."
      redirect_to @resource
    end
  end

  def destroy
    @resource = Resource.find(params[:id])
    command = DeleteResourceCommand.new(@resource, current_user,
                                        request.remote_ip)
    begin
      command.execute
    rescue => e
      flash[:error] = "#{e}"
      redirect_to @resource
    else
      flash[:success] = "Resource \"#{@resource.name}\" deleted."
      redirect_to @resource.location
    end
  end

  # Responds to /resources/:id/assess
  def edit
    @resource = Resource.find(params[:id])

    # The form JavaScript needs at least 1 of each dependent entity. Empty
    # ones will be stripped in update().
    @resource.creators.build unless @resource.creators.any?
    @resource.extents.build unless @resource.extents.any?
    @resource.resource_dates.build unless @resource.resource_dates.any?
    @resource.resource_notes.build unless @resource.resource_notes.any?
    @resource.subjects.build unless @resource.subjects.any?

    @assessment_sections = Assessment.find_by_key('resource').
        assessment_sections.order(:index)

    @resource.associate_assessment_question_responses
  end

  # Responds to POST /locations/:id/resources/import
  def import
    @location = Location.find params[:location_id]

    command = ImportFromArchivesspaceEadCommand.new(
        resource_import_params, current_user, request.remote_ip)
    begin
      command.execute
    rescue => e
      flash[:error] = "#{e}"
      @import = command.object
      render 'import'
    else
      flash[:success] = "Successfully imported resource "\
      "\"#{command.created_resource.name}\"."
      redirect_to @location
    end
  end

  ##
  # Responds to /institutions/:id/resources/names
  def names
    render json: Resource.
        joins('LEFT JOIN locations ON locations.id = resources.location_id').
        joins('LEFT JOIN repositories ON locations.repository_id = repositories.id').
        joins('LEFT JOIN institutions ON repositories.institution_id = institutions.id').
        where('institutions.id = ?', params[:institution_id]).
        map{ |r| r.name }
  end

  def new
    # if we are creating a resource within a location (for top-level resources)
    if params[:location_id]
      @location = Location.find(params[:location_id])
      @resource = @location.resources.build
    elsif params[:resource_id] # if we are creating a resource within a resource
      parent_resource = Resource.find(params[:resource_id])
      @location = parent_resource.location
      @resource = @location.resources.build
      @resource.parent = parent_resource
    end

    # New resources will get 1 of each dependent entity, to populate the form.
    # Additional ones may be created in JavaScript.
    @resource.creators.build
    @resource.extents.build
    @resource.resource_dates.build
    @resource.resource_notes.build
    @resource.subjects.build

    @resource.language = @resource.location.repository.institution.language

    @assessment_sections = Assessment.find_by_key('resource').
        assessment_sections.order(:index)

    @resource.associate_assessment_question_responses
  end

  def show
    @resource = Resource.find(params[:id])
    @assessment_sections = Assessment.find_by_key('resource').
        assessment_sections.order(:index)

    respond_to do |format|
      format.html {
        @events = @resource.events.order(created_at: :desc)
      }
      format.dcxml {
        response.headers['Content-Disposition'] =
            "attachment; filename=\"#{@resource.dcxml_filename}\""
        @institution = @resource.location.repository.institution
      }
      format.ead {
        response.headers['Content-Disposition'] =
            "attachment; filename=\"#{@resource.ead_filename}\""
        @institution = @resource.location.repository.institution
      }
    end
  end

  def update
    @resource = Resource.find(params[:id])
    command = UpdateResourceCommand.new(@resource, resource_params,
                                        current_user, request.remote_ip)
    @assessment_sections = Assessment.find_by_key('resource').
        assessment_sections.order(:index)
    begin
      command.execute
    rescue ValidationError
      render 'edit'
    rescue => e
      flash[:error] = "#{e}"
      render 'edit'
    else
      flash[:success] = "Resource \"#{@resource.name}\" updated."
      respond_to do |format|
        format.html { redirect_to edit_resource_url(@resource) }
        format.js { render 'edit' }
      end
    end
  end

  private

  def user_of_same_institution_or_admin
    # Normal users can only modify resources in their own institution.
    # Administrators can edit any resource.
    if params[:id]
      resource = Resource.find(params[:id])
      institution = resource.location.repository.institution
    elsif params[:location_id]
      institution = Location.find(params[:location_id]).repository.institution
    elsif params[:resource_id]
      parent_resource = Resource.find(params[:resource_id])
      institution = parent_resource.location.repository.institution
    elsif params[:institution_id]
      institution = Institution.find(params[:institution_id])
    end
    redirect_to(root_url) unless institution.users.include?(current_user) ||
            current_user.is_admin?
  end

  def resource_import_params
    params.require(:archivesspace_import).permit(:host, :password, :port,
                                                 :resource_id, :username)
  end

  def resource_params
    params.require(:resource).permit(:description, :format_id,
                                     :local_identifier, :location_id, :name,
                                     :notes, :parent_id, :resource_type,
                                     :significance, :user_id,
                                     creators_attributes: [:id, :creator_type,
                                                           :name],
                                     extents_attributes: [:id, :name],
                                     resource_dates_attributes:
                                         [:id, :date_type, :begin_year,
                                          :begin_month, :begin_day, :end_year,
                                          :end_month, :end_day, :year, :month,
                                          :day],
                                     resource_notes_attributes: [:id, :value],
                                     subjects_attributes: [:id, :name]).tap do |whitelisted|
      whitelisted[:assessment_question_responses_attributes] =
          params[:resource][:assessment_question_responses_attributes] if
          params[:resource][:assessment_question_responses_attributes]
    end
  end

end
