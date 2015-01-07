class InstitutionsController < ApplicationController

  include PrawnCharting

  before_action :signed_in_user
  before_action :admin_user, only: [:index, :destroy]
  before_action :same_institution_user, only: [:assessment_report, :events,
                                               :repositories, :resources,
                                               :show, :edit, :update, :users]

  ##
  # Responds to GET /institutions/:id/assessment-report
  #
  def assessment_report
    @institution = Institution.find(params[:institution_id])

    @location_assessment_sections = Assessment.find_by_key('location').
        assessment_sections.order(:index)
    @non_assessed_locations = @institution.locations.order(:name).
        select{ |l| l.assessment_question_responses.length < 1 }
    @non_assessed_resources = @institution.resources.order(:name).
        select{ |r| r.assessment_question_responses.length < 1 }
    @stats = @institution.assessed_item_statistics
    @institution_formats = @institution.resources.collect{ |r| r.format }.
        select{ |f| f }.uniq{ |f| f.id }
    @collections = @institution.resources.
        where(resource_type: ResourceType::COLLECTION)

    @resource_chart_data = []
    (0..9).each do |i|
      sql = "SELECT COUNT(resources.id) AS count "\
          "FROM resources "\
          "LEFT JOIN locations ON locations.id = resources.location_id "\
          "LEFT JOIN repositories ON repositories.id = locations.repository_id "\
          "WHERE repositories.institution_id = #{@institution.id} "\
          "AND resources.assessment_score >= #{i * 0.1} "\
          "AND resources.assessment_score < #{(i + 1) * 0.1} "
      @resource_chart_data << ActiveRecord::Base.connection.execute(sql).
          map{ |r| r['count'].to_i }.first
    end

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
          "AND resources.assessment_score < #{(i + 1) * 0.1} "
        data << ActiveRecord::Base.connection.execute(sql).
            map{ |r| r['count'].to_i }.first
      end
      @collection_chart_datas[collection.id] = data
    end

    respond_to do |format|
      format.html
      format.pdf do
        pdf = pdf_assessment_report(@institution, current_user,
                                    @resource_chart_data,
                                    @collection_chart_datas,
                                    @location_assessment_sections,
                                    @institution_formats, @collections)
        send_data pdf.render, filename: 'assessment_report.pdf',
                  type: 'application/pdf', disposition: 'inline'
      end
    end
  end

  def create
    command = CreateAndJoinInstitutionCommand.new(
        institution_params, current_user, request.remote_ip)
    @institution = command.object
    @assessment_sections = Assessment.find_by_key('institution').
        assessment_sections.order(:index)
    begin
      command.execute
    rescue ValidationError
      render 'new'
    rescue => e
      flash[:error] = "#{e}"
      render 'new'
    else
      flash[:success] = "The institution \"#{@institution.name}\" has been "\
        "created. An administrator has been notified and will review your "\
        "request to join it momentarily,"
      redirect_to dashboard_path
    end
  end

  def destroy
    @institution = Institution.find(params[:id])
    command = DeleteInstitutionCommand.new(@institution, current_user,
                                           request.remote_ip)
    begin
      command.execute
    rescue => e
      flash[:error] = "#{e}"
      redirect_to institution_url(@institution)
    else
      flash[:success] = "Institution \"#{@institution.name}\" deleted."
      redirect_to institutions_url
    end
  end

  def edit
    @institution = Institution.find(params[:id])
    @assessment_sections = Assessment.find_by_key('institution').
        assessment_sections.order(:index)
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
    @institutions = Institution.order(:name).paginate(
        page: params[:page],
        per_page: Psap::Application.config.results_per_page)
  end

  def new
    @institution = Institution.new
    @assessment_sections = Assessment.find_by_key('institution').
        assessment_sections.order(:index)
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
    # show only top-level resources
    @resources = @institution.resources.where(parent_id: nil).order(:name).
        paginate(page: params[:page],
                 per_page: Psap::Application.config.results_per_page)
  end

  def show
    @institution = Institution.find(params[:id])

    respond_to do |format|
      format.csv do
        #response.headers['Content-Disposition'] =
        #    "attachment; filename=\"#{@institution.name.parameterize}\""
        render text: @institution.resources_as_csv
      end
      format.html do
        @assessment_sections = Assessment.find_by_key('institution').
            assessment_sections.order(:index)
        @repositories = @institution.repositories.order(:name).
            paginate(page: params[:page],
                     per_page: Psap::Application.config.results_per_page)
        render 'repositories'
      end
    end
  end

  def update
    @institution = Institution.find(params[:id])
    command = UpdateInstitutionCommand.new(@institution, institution_params,
                                           current_user, request.remote_ip)
    @assessment_sections = Assessment.find_by_key('institution').
        assessment_sections.order(:index)
    begin
      command.execute
    rescue ValidationError
      render 'edit'
    rescue => e
      flash[:error] = "#{e}"
      render 'edit'
    else
      flash[:success] = "Institution \"#{@institution.name}\" updated."
      redirect_to edit_institution_url(@institution)
    end
  end

  def users
    @institution = Institution.find(params[:institution_id])
    @institution_users = @institution.users.where(confirmed: true).order(:last_name)
  end

  private

  def same_institution_user
    # Normal users can only edit their own institution. Administrators can edit
    # any institution.
    if params[:id]
      institution = Institution.find(params[:id])
    else
      institution = Institution.find(params[:institution_id])
    end
    redirect_to(root_url) unless
        institution.users.include?(current_user) || current_user.is_admin?
  end

  def institution_params
    params.require(:institution).permit(:name, :address1, :address2, :city,
                                        :state, :postal_code, :country, :url,
                                        :description, :email).tap do |whitelisted|
      # AQRs don't use Rails' nested params format, and will require additional
      # processing
      whitelisted[:assessment_question_responses] =
          params[:institution][:assessment_question_responses] if
          params[:institution][:assessment_question_responses]
    end
  end

end
