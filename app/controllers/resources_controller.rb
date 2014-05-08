class ResourcesController < ApplicationController

  before_action :signed_in_user
  before_action :user_of_same_institution_or_admin, only: [:new, :create,
                                                           :edit, :import,
                                                           :update, :show,
                                                           :destroy]

  def create
    @location = Location.find(params[:location_id])
    command = CreateResourceCommand.new(@location, resource_params,
                                        current_user, request.remote_ip)
    @resource = command.object
    begin
      command.execute
    rescue => e
      flash[:error] = "#{e}"
      @assessment_sections = Assessment.find_by_key('resource').
          assessment_sections.order(:index)
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

  def edit
    @resource = Resource.find(params[:id])

    # The form JavaScript needs at least 1 of each dependent entity. Empty
    # ones will be stripped in update().
    @resource.creators.build unless @resource.creators.any?
    @resource.extents.build unless @resource.extents.any?
    @resource.resource_dates.build unless @resource.resource_dates.any?
    @resource.subjects.build unless @resource.subjects.any?

    @assessment_sections = Assessment.find_by_key('resource').
        assessment_sections.order(:index)
  end

  # Responds to GET/POST /locations/:id/resources/import
  def import
    @location = Location.find params[:location_id]

    case request.method
      when 'GET'
        @import = ArchivesspaceImport.new
        @import.port = 80
        render 'import'
      when 'POST'
        command = ImportFromArchivesspaceEadCommand.new(
            resource_import_params, current_user, request.remote_ip)
        begin
          command.execute
        rescue => e
          flash[:error] = "#{e}"
          @import = command.object
          render 'import'
        else
          flash[:success] = 'Successfully imported resource.'
          redirect_to @location
        end
    end
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

    @assessment_sections.each do |section|
      section.assessment_questions.each do |question|
        @resource.assessment_question_responses <<
            AssessmentQuestionResponse.new(assessment_question: question)
      end
    end
  end

  def show
    @resource = Resource.find(params[:id])
    @assessment_sections = Assessment.find_by_key('resource').
        assessment_sections.order(:index)

    respond_to do |format|
      format.html
      format.xml { @institution = @resource.location.repository.institution }
    end
  end

  def update
    @resource = Resource.find(params[:id])
    command = UpdateResourceCommand.new(@resource, resource_params,
                                        current_user, request.remote_ip)
    begin
      command.execute
    rescue => e
      @assessment_sections = Assessment.find_by_key('resource').
          assessment_sections.order(:index)
      flash[:error] = "#{e}"
      render 'edit'
    else
      flash[:success] = "Resource \"#{@resource.name}\" updated."
      redirect_to edit_resource_url(@resource)
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

  def resource_import_params
    params.require(:archivesspace_import).permit(:host, :password, :port,
                                                 :resource_id, :username)
  end

  def resource_params
    params.require(:resource).permit(:description, :format_id,
                                     :local_identifier, :location_id, :name,
                                     :notes, :resource_type, :user_id,
                                     assessment_question_responses_attributes:
                                         [:id, :assessment_question_option_id],
                                     creators_attributes: [:id, :creator_type,
                                                           :name],
                                     extents_attributes: [:id, :name],
                                     resource_dates_attributes:
                                         [:id, :date_type, :begin_year,
                                          :begin_month, :begin_day, :end_year,
                                          :end_month, :end_day, :year, :month,
                                          :day],
                                     subjects_attributes: [:id, :name])
  end

end
