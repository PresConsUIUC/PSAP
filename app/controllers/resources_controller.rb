class ResourcesController < ApplicationController

  before_action :signed_in_user
  before_action :user_of_same_institution_or_admin,
                only: [:assess, :create, :destroy, :import, :names, :new,
                       :show, :subjects, :update]

  ##
  # Responds to GET /resources/:id/assess
  #
  def assess
    @resource = Resource.find(params[:resource_id])
    @assessment_sections = Assessment.find_by_key('resource').
        assessment_sections.order(:index)
  end

  def create
    @location = Location.find(params[:location_id])
    command = CreateResourceCommand.new(@location, resource_params,
                                        current_user, request.remote_ip)
    @resource = command.object
    begin
      command.execute
    rescue ValidationError
      render 'new'
    rescue => e
      flash['error'] = "#{e}"
      render 'new'
    else
      flash['success'] = "Resource \"#{@resource.name}\" created."
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
      flash['error'] = "#{e}"
      redirect_to @resource
    else
      flash['success'] = "Resource \"#{@resource.name}\" deleted."
      redirect_to @resource.location
    end
  end

  ##
  # Responds to POST /locations/:id/resources/import
  #
  def import
    if params[:location_id]
      @location = Location.find(params[:location_id])
    elsif params[:resource_id]
      @parent_resource = Resource.find(params[:resource_id])
      @location = @parent_resource.location
    end

    command = ImportArchivesspaceEadCommand.new(
        params[:files], @parent_resource, current_user, request.remote_ip)
    begin
      command.execute
    rescue => e
      flash['error'] = "#{e}"
      redirect_to :back
    else
      if command.object.length > 0
        flash['success'] = "Successfully imported #{command.object.length} "\
        "resource(s)."
      else
        flash[:notice] = 'Unable to detect an ArchivesSpace EAD XML file in '\
        'any of the uploaded files.'
      end
      redirect_to :back
    end
  end

  ##
  # Responds to /resources/move
  def move
    resources = Resource.where('id IN (?)', params[:resources])
    location = Location.find(params[:location_id])

    command = MoveResourcesCommand.new(resources, location, current_user,
                                       request.remote_ip)
    begin
      command.execute
    rescue => e
      flash['error'] = "#{e}"
    else
      flash['success'] = "Successfully moved resources to "\
      "\"#{command.object.name}\"."
    end
    redirect_to :back
  end

  ##
  # Responds to /institutions/:id/resources/names
  def names
    sql = 'SELECT DISTINCT resources.name '\
    'FROM resources '\
    'LEFT JOIN locations ON locations.id = resources.location_id '\
    'LEFT JOIN repositories ON locations.repository_id = repositories.id '\
    'LEFT JOIN institutions ON repositories.institution_id = institutions.id '\
    'WHERE institutions.id = ' + params[:institution_id].to_i.to_s
    conn = ActiveRecord::Base.connection
    results = conn.execute(sql)
    render json: results.map{ |r| r['name'] }
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
  end

  def show
    @resource = Resource.find(params[:id])
    @assessment_sections = Assessment.find_by_key('resource').
        assessment_sections.order(:index)

    respond_to do |format|
      format.csv do
        response.headers['Content-Disposition'] =
            "attachment; filename=\"#{@resource.filename}.csv\""
        render text: @resource.as_csv
      end
      format.html do
        # The edit form JavaScript needs at least 1 of each dependent entity.
        # Empty ones will be stripped in update().
        @resource.creators.build unless @resource.creators.any?
        @resource.extents.build unless @resource.extents.any?
        @resource.resource_dates.build unless @resource.resource_dates.any?
        @resource.resource_notes.build unless @resource.resource_notes.any?
        @resource.subjects.build unless @resource.subjects.any?

        @events = @resource.events.order(created_at: :desc)
      end
      format.dcxml do
        response.headers['Content-Disposition'] =
            "attachment; filename=\"#{@resource.filename}.xml\""
        @institution = @resource.location.repository.institution
      end
      format.ead do
        response.headers['Content-Disposition'] =
            "attachment; filename=\"#{@resource.filename}.xml\""
        @institution = @resource.location.repository.institution
      end
      format.js do
        # The edit form JavaScript needs at least 1 of each dependent entity.
        # Empty ones will be stripped in update().
        @resource.creators.build unless @resource.creators.any?
        @resource.extents.build unless @resource.extents.any?
        @resource.resource_dates.build unless @resource.resource_dates.any?
        @resource.resource_notes.build unless @resource.resource_notes.any?
        @resource.subjects.build unless @resource.subjects.any?

        @events = @resource.events.order(created_at: :desc)
      end
    end
  end

  ##
  # Responds to /institutions/:id/resources/subjects
  def subjects
    sql = 'SELECT DISTINCT subjects.name '\
    'FROM subjects '\
    'LEFT JOIN resources ON subjects.resource_id = resources.id '\
    'LEFT JOIN locations ON locations.id = resources.location_id '\
    'LEFT JOIN repositories ON locations.repository_id = repositories.id '\
    'LEFT JOIN institutions ON repositories.institution_id = institutions.id '\
    'WHERE institutions.id = ' + params[:institution_id].to_i.to_s
    conn = ActiveRecord::Base.connection
    results = conn.execute(sql)
    render json: results.map(&:name)
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
      render partial: 'show_error'
    rescue => e
      flash['error'] = "#{e}"
      render 'show'
    else
      flash['success'] = "Resource \"#{@resource.name}\" updated."
      render 'show'
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
    if institution
      redirect_to(root_url) unless institution.users.include?(current_user) or
              current_user.is_admin?
    end
  end

  def resource_params
    params.require(:resource).permit(:assessment_type, :description,
                                     :format_id, :format_ink_media_type_id,
                                     :format_support_type_id,
                                     :local_identifier, :location_id, :name,
                                     :notes, :parent_id, :resource_type,
                                     :rights, :significance, :user_id,
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
      # AQRs don't use Rails' nested params format, and will require additional
      # processing
      whitelisted[:assessment_question_responses] =
          params[:resource][:assessment_question_responses] if
          params[:resource][:assessment_question_responses]
    end
  end

end
