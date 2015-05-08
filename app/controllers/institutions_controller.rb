class InstitutionsController < ApplicationController

  include PrawnCharting

  before_action :signed_in_user
  before_action :admin_user, only: [:index, :destroy]
  before_action :same_institution_user,
                only: [:assess, :assessment_report, :edit, :events, :info,
                       :repositories, :resources, :show, :update, :users]

  def assess
    if request.xhr?
      @institution = Institution.find(params[:institution_id])
      @assessment_sections = Assessment.find_by_key('institution').
          assessment_sections.order(:index)
      render partial: 'assess_form', locals: { action: :assess }
    else
      render status: 406, text: 'Not Acceptable'
    end
  end

  ##
  # Responds to GET /institutions/:id/assessment-report
  # Add a .pdf extension to get a PDF. Optionally, pass one of the following
  # ?section= parameters to get just that section: preservation, storage,
  # resources, collections
  #
  def assessment_report
    @institution = Institution.find(params[:institution_id])

    if [nil, 'storage'].include?(params[:section])
      @location_assessment_sections = Assessment.find_by_key('location').
          assessment_sections.order(:index)
    end
    if [nil, 'collections'].include?(params[:section])
      @collections = @institution.resources.
          where(resource_type: ResourceType::COLLECTION)
      @collection_chart_datas = {}
      @collections.each do |collection|
        sub_collections = collection.all_children.select{ |r|
          r.resource_type == ResourceType::COLLECTION }
        sub_collections << collection
        parent_ids = sub_collections.map{ |r| r.id }.join(', ')
        data = []
        (0..9).each do |i|
          sql = "SELECT COUNT(resources.id) AS count "\
          "FROM resources "\
          "WHERE resources.parent_id IN (#{parent_ids}) "\
          "AND resources.assessment_score >= #{i * 0.1} "\
          "AND resources.assessment_score < #{(i + 1) * 0.1} "\
          "AND resources.assessment_score > 0.00001 " # virtually all of these will be non-assessed
          data << ActiveRecord::Base.connection.execute(sql).
              map{ |r| r['count'].to_i }.first
        end
        @collection_chart_datas[collection.id] = data
      end
    end
    if [nil, 'resources'].include?(params[:section])
      @institution_formats = @institution.resources.collect{ |r| r.format }.
          select{ |f| f }.uniq{ |f| f.id }
      @resource_chart_data = []
      (0..9).each do |i|
        sql = "SELECT COUNT(resources.id) AS count "\
            "FROM resources "\
            "LEFT JOIN locations ON locations.id = resources.location_id "\
            "LEFT JOIN repositories ON repositories.id = locations.repository_id "\
            "WHERE repositories.institution_id = #{@institution.id} "\
            "AND resources.assessment_score >= #{i * 0.1} "\
            "AND resources.assessment_score < #{(i + 1) * 0.1} "\
            "AND resources.assessment_score > 0.00001 " # virtually all of these will be non-assessed
        @resource_chart_data << ActiveRecord::Base.connection.execute(sql).
            map{ |r| r['count'].to_i }.first
      end
    end

    respond_to do |format|
      format.html { @stats = @institution.assessed_item_statistics }
      format.pdf do
        case params[:section]
          when 'preservation'
            pdf = pdf_preservation_assessment_report(
                nil, @institution, current_user)
          when 'storage'
            pdf = pdf_storage_assessment_report(
                nil, @institution, current_user, @location_assessment_sections)
          when 'resources'
            pdf = pdf_resources_assessment_report(
                nil, @institution, current_user, @institution_formats,
                @resource_chart_data)
          when 'collections'
            pdf = pdf_collections_assessment_report(
                nil, @institution, current_user, @collections,
                @collection_chart_datas)
          else
            pdf = pdf_assessment_report(@institution, current_user,
                                        @resource_chart_data,
                                        @collection_chart_datas,
                                        @location_assessment_sections,
                                        @institution_formats, @collections)
        end
        send_data pdf.render, filename: 'assessment_report.pdf',
                  type: 'application/pdf', disposition: 'inline'
      end
    end
  end

  def create
    create_command = CreateInstitutionCommand.new(
        institution_params, current_user, request.remote_ip)
    @institution = create_command.object
    begin
      ActiveRecord::Base.transaction do
        create_command.execute
        unless current_user.is_admin?
          join_command = JoinInstitutionCommand.new(current_user,
                                                    @institution, current_user,
                                                    request.remote_ip)
          join_command.execute
        end
      end
    rescue ValidationError
      response.headers['X-Psap-Result'] = 'error'
      render partial: 'shared/validation_messages',
             locals: { entity: @institution }
    rescue => e
      response.headers['X-Psap-Result'] = 'error'
      flash['error'] = "#{e}"
      render 'create'
    else
      response.headers['X-Psap-Result'] = 'success'
      if current_user.is_admin?
        flash['success'] = "The institution \"#{@institution.name}\" has been "\
        "created."
        prepare_index_view
        render 'create'
      else
        flash['success'] = "The institution \"#{@institution.name}\" has been "\
          "created. An administrator has been notified and will review your "\
          "request to join it soon."
      end
    end
  end

  def destroy
    @institution = Institution.find(params[:id])
    command = DeleteInstitutionCommand.new(@institution, current_user,
                                           request.remote_ip)
    begin
      command.execute
    rescue => e
      flash['error'] = "#{e}"
      redirect_to institution_url(@institution)
    else
      flash['success'] = "Institution \"#{@institution.name}\" deleted."
      redirect_to institutions_url
    end
  end

  def edit
    if request.xhr?
      @institution = Institution.find(params[:id])
      render partial: 'edit_form', locals: { action: :edit }
    else
      render status: 406, text: 'Not Acceptable'
    end
  end

  def events
    @institution = Institution.find(params[:institution_id])
    @events = Event.
        joins('LEFT JOIN events_institutions ON events_institutions.event_id = events.id').
        joins('LEFT JOIN events_repositories ON events_repositories.event_id = events.id').
        joins('LEFT JOIN events_locations ON events_locations.event_id = events.id').
        joins('LEFT JOIN events_resources ON events_resources.event_id = events.id').
        where('events_institutions.institution_id = ? '\
        'OR events_repositories.repository_id IN (?) '\
        'OR events_locations.location_id IN (?)'\
        'OR events_resources.resource_id IN (?)',
              @institution.id,
              @institution.repositories.map { |repo| repo.id },
              @institution.repositories.map { |repo| repo.locations.map { |loc| loc.id } }.flatten.compact,
              @institution.repositories.map { |repo| repo.locations.map {
                  |loc| loc.resources.map { |res| res.id } } }.flatten.compact).
        order(created_at: :desc).
        limit(20)
  end

  def index
    prepare_index_view
  end

  def info
    @institution = Institution.find(params[:institution_id])
  end

  def new
    if request.xhr?
      @institution = Institution.new
      render partial: 'edit_form', locals: { action: :create }
    else
      render status: 406, text: 'Not Acceptable'
    end
  end

  ##
  # Responds to GET /institutions/:id/repositories
  #
  def repositories
    @institution = Institution.find(params[:institution_id])
    @repositories = @institution.repositories.order(:name).
        paginate(page: params[:page],
                 per_page: Psap::Application.config.results_per_page)
  end

  ##
  # Responds to GET /institutions/:id/resources
  #
  def resources
    @institution = Institution.find(params[:institution_id])
    @resources = @institution.resources
    @searching = false

    # all available URL query parameters
    query_keys = [:assessed, :format_id, :language_id, :q, :repository_id,
                  :resource_type, :score, :score_direction, :user_id]
    if query_keys.select{ |k| !params.key?(k) }.length == query_keys.length
      # no search query input present; show only top-level resources
      @resource_count = @resources.count
      @resources = @resources.where(parent_id: nil).order(:name)
    else
      @resources = Resource.all_matching_query(current_user.institution,
                                               params, @resources)
      @resource_count = @resources.count
      @searching = true
    end

    if request.xhr?
      @resources = @resources.
          paginate(page: params[:page],
                   per_page: Psap::Application.config.results_per_page)
      render 'resources'
    else
      respond_to do |format|
        format.csv do
          response.headers['Content-Disposition'] =
              'attachment; filename="resources.csv"'
          render text: Resource.as_csv(@resources)
        end
        format.json
        format.html do
          @resources = @resources.
              paginate(page: params[:page],
                       per_page: Psap::Application.config.results_per_page)
        end
      end
    end
  end

  def show
    prepare_show_view
    render 'repositories'
  end

  def update
    @institution = Institution.find(params[:id])
    command = UpdateInstitutionCommand.new(@institution, institution_params,
                                           current_user, request.remote_ip)
    begin
      command.execute
    rescue ValidationError
      response.headers['X-Psap-Result'] = 'error'
      render partial: 'shared/validation_messages',
             locals: { entity: @institution }
    rescue => e
      response.headers['X-Psap-Result'] = 'error'
      flash['error'] = "#{e}"
      render 'info'
    else
      prepare_show_view
      response.headers['X-Psap-Result'] = 'success'
      flash['success'] = "Institution \"#{@institution.name}\" updated."
      render 'info'
    end
  end

  def users
    @institution = Institution.find(params[:institution_id])
    @institution_users = @institution.users.where(confirmed: true).order(:last_name)
  end

  private

  def prepare_index_view
    @institutions = Institution.order(:name).paginate(
        page: params[:page],
        per_page: Psap::Application.config.results_per_page)
  end

  def prepare_show_view
    @institution = Institution.find(params[:id])
    @repositories = @institution.repositories.order(:name).
        paginate(page: params[:page],
                 per_page: Psap::Application.config.results_per_page)
  end

  def same_institution_user
    # Normal users can only edit their own institution. Administrators can edit
    # any institution.
    if params[:id]
      institution = Institution.find(params[:id])
    else
      institution = Institution.find(params[:institution_id])
    end
    redirect_to(root_url) unless
        institution.users.include?(current_user) or current_user.is_admin?
  end

  def institution_params
    params.require(:institution).permit(:address1, :address2, :city, :country,
                                        :description, :email, :language_id,
                                        :name, :postal_code, :state, :url).tap do |whitelisted|
      # AQRs don't use Rails' nested params format, and will require additional
      # processing
      whitelisted[:assessment_question_responses] =
          params[:institution][:assessment_question_responses] if
          params[:institution][:assessment_question_responses]
    end
  end

end
