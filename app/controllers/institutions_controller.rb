class InstitutionsController < ApplicationController

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

  def index
    prepare_index_view
  end

  def new
    if request.xhr?
      @institution = Institution.new
      render partial: 'edit_form', locals: { action: :create }
    else
      render status: 406, text: 'Not Acceptable'
    end
  end

  def show
    prepare_show_view
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

  private

  def prepare_index_view
    @institutions = Institution.order(:name).paginate(
        page: params[:page],
        per_page: Psap::Application.config.results_per_page)
  end

  def prepare_show_view
    @institution = Institution.find(params[:id])

    # data for repositories tab
    @repositories = @institution.repositories.order(:name).
        paginate(page: params[:page],
                 per_page: Psap::Application.config.results_per_page)

    # data for users tab
    @institution_users = @institution.users.where(confirmed: true).order(:last_name)

    # data for events tab
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
