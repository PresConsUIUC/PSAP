class ResourcesController < ApplicationController

  NUM_DEPENDENT_FORM_ENTITIES = 8

  before_action :signed_in_user
  before_action :user_of_same_institution_or_admin,
                only: [:assess, :create, :destroy, :edit, :import, :names, :new,
                       :show, :subjects, :update]

  ##
  # Responds to GET /resources/:id/assess
  #
  def assess
    if request.xhr?
      @resource = Resource.find(params[:resource_id])
      @assessment_sections = Assessment.find_by_key('resource').
          assessment_sections.order(:index)
      render partial: 'assess_form', locals: { action: :assess }
    else
      render status: 406, text: 'Not Acceptable'
    end
  end

  ##
  # Responds to PATCH /resources/:id/clone
  # Supports ?omit_assessment_data=[true/false] to optionally omit assessment
  # data
  #
  def clone
    @resource = Resource.find(params[:resource_id])
    command = CloneResourceCommand.new(@resource, params[:omit_assessment_data],
                                       current_user, request.remote_ip)
    begin
      command.execute
    rescue => e
      flash['error'] = "#{e}"
      redirect_to :back
    else
      flash['success'] = "Cloned #{@resource.name} as "\
      "\"#{command.object.name}\"."
      redirect_to command.object
    end
  end

  def create
    @location = Location.find(params[:location_id])
    command = CreateResourceCommand.new(@location, resource_params,
                                        current_user, request.remote_ip)
    @resource = command.object
    begin
      command.execute
    rescue ValidationError
      response.headers['X-Psap-Result'] = 'error'
      render partial: 'shared/validation_messages',
             locals: { entity: @resource }
    rescue => e
      response.headers['X-Psap-Result'] = 'error'
      flash['error'] = "#{e}"
      keep_flash
      render 'create'
    else
      response.headers['X-Psap-Result'] = 'success'
      flash['success'] = "Resource \"#{@resource.name}\" created."
      keep_flash
      render 'create'
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
  # Responds to GET /resources/:id/edit
  #
  def edit
    if request.xhr?
      @resource = Resource.find(params[:id])
      add_dependent_entities
      render partial: 'edit_form', locals: { action: :edit }
    else
      render status: 406, text: 'Not Acceptable'
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
        params[:files], @parent_resource, @location, current_user,
        request.remote_ip)
    begin
      command.execute
    rescue => e
      flash['error'] = "#{e}"
      redirect_to :back
    else
      if command.object.length > 0
        flash['success'] = "Imported #{command.object.length} resource(s)."
      else
        flash[:notice] = 'Unable to detect an ArchivesSpace EAD XML file in '\
        'any of the uploaded files.'
      end
      redirect_to :back
    end
  end

  ##
  # Responds to POST /resources/move
  #
  def move
    if params[:location_id]
      resources = Resource.where('id IN (?)', params[:resources])
      location = Location.find(params[:location_id])

      command = MoveResourcesCommand.new(resources, location, current_user,
                                         request.remote_ip)
      begin
        command.execute
      rescue => e
        flash['error'] = "#{e}"
      else
        flash['success'] = "Moved #{resources.length} resources to "\
        "\"#{command.object.name}\"."
      end
    else
      flash['error'] = 'No location selected.'
    end
    redirect_to :back
  end

  ##
  # Responds to GET /institutions/:id/resources/names
  #
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
    if request.xhr?
      @location = Location.find(params[:location_id])
      @resource = @location.resources.build

      # if we are creating a resource within a resource, we should expect a
      # parent_id URL query parameter
      @resource.parent = Resource.find(params[:parent_id]) if params[:parent_id]

      # New resources will get 8 of each dependent entity, to populate the form.
      # Additional ones may be created in JavaScript.
      NUM_DEPENDENT_FORM_ENTITIES.times do
        @resource.creators.build
        @resource.extents.build
        @resource.resource_dates.build
        @resource.resource_notes.build
        @resource.subjects.build
      end

      @resource.language = @resource.location.repository.institution.language

      render partial: 'edit_form', locals: { action: :create }
    else
      render status: 406, text: 'Not Acceptable'
    end
  end

  def show
    @resource = Resource.find(params[:id])
    respond_to do |format|
      format.csv do
        response.headers['Content-Disposition'] =
            "attachment; filename=\"#{@resource.filename}.csv\""
        render text: @resource.as_csv
      end
      format.html do
        prepare_show_view
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
        prepare_show_view
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
    render json: results.map{ |r| r['name'] }
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
      response.headers['X-Psap-Result'] = 'error'
      render partial: 'shared/validation_messages',
             locals: { entity: @resource }
    rescue => e
      response.headers['X-Psap-Result'] = 'error'
      flash['error'] = "#{e}"
      render 'show'
    else
      prepare_show_view
      response.headers['X-Psap-Result'] = 'success'
      flash['success'] = "Resource \"#{@resource.name}\" updated."
      render 'show'
    end
  end

  private

  ##
  # The edit form needs NUM_DEPENDENT_FORM_ENTITIES of each dependent entity.
  # Empty ones will be stripped in update().
  #
  def add_dependent_entities
    (NUM_DEPENDENT_FORM_ENTITIES - @resource.creators.length).times do
      @resource.creators.build
    end
    (NUM_DEPENDENT_FORM_ENTITIES - @resource.extents.length).times do
      @resource.extents.build
    end
    (NUM_DEPENDENT_FORM_ENTITIES - @resource.resource_dates.length).times do
      @resource.resource_dates.build
    end
    (NUM_DEPENDENT_FORM_ENTITIES - @resource.resource_notes.length).times do
      @resource.resource_notes.build
    end
    (NUM_DEPENDENT_FORM_ENTITIES - @resource.subjects.length).times do
      @resource.subjects.build
    end
  end

  def prepare_show_view
    @assessment_sections = Assessment.find_by_key('resource').
        assessment_sections.order(:index)
    add_dependent_entities
    @events = @resource.events.order(created_at: :desc).limit(20)
  end

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
    params.require(:resource).
        permit(:assessment_type, :description, :format_id,
               :format_ink_media_type_id, :format_support_type_id,
               :local_identifier, :location_id, :name, :notes, :parent_id,
               :resource_type, :rights, :significance, :user_id,
               creators_attributes: [:_destroy, :id, :creator_type, :name],
               extents_attributes: [:_destroy, :id, :name],
               resource_dates_attributes: [:_destroy, :id, :date_type,
                                           :begin_year, :begin_month,
                                           :begin_day, :end_year, :end_month,
                                           :end_day, :year, :month, :day],
               resource_notes_attributes: [:_destroy, :id, :value],
               subjects_attributes: [:_destroy, :id, :name]).tap do |whitelisted|
      # AQRs don't use Rails' nested params format, and will require additional
      # processing
      whitelisted[:assessment_question_responses] =
          params[:resource][:assessment_question_responses] if
          params[:resource][:assessment_question_responses]
    end
  end

end
