class InstitutionsController < ApplicationController

  before_action :signed_in_user
  before_action :admin_user, only: [:index, :destroy]
  before_action :same_institution_user, only: [:show, :edit, :update]

  def create
    command = CreateInstitutionCommand.new(institution_params, current_user,
                                           request.remote_ip)
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
        "created, and you have automatically been added to it."
      redirect_to @institution
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

  def show
    @institution = Institution.find(params[:id])

    respond_to do |format|
      format.csv {
        #response.headers['Content-Disposition'] =
        #    "attachment; filename=\"#{@institution.name.parameterize}\""
        render text: @institution.resources_as_csv
      }
      format.html {
        @assessment_sections = Assessment.find_by_key('institution').
            assessment_sections.order(:index)
        @institution_users = @institution.users.where(confirmed: true).order(:last_name)
        @repositories = @institution.repositories.order(:name).
            paginate(page: params[:page],
                     per_page: Psap::Application.config.results_per_page)
        # show only top-level resources
        @resources = @institution.resources.where(parent_id: nil).order(:name).
            paginate(page: params[:page],
                     per_page: Psap::Application.config.results_per_page)
        @non_assessed_locations = @institution.locations.order(:name).
            select{ |l| l.assessment_question_responses.length < 1 }
        @non_assessed_resources = @institution.resources.order(:name).
            select{ |r| r.assessment_question_responses.length < 1 }
        @location_assessment_sections = Assessment.find_by_key('location').
            assessment_sections.order(:index)

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
      }
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

  # Outputs a high-level assessment report as a PDF.
  def report
    # TODO: write this
  end

  private

  def same_institution_user
    # Normal users can only edit their own institution. Administrators can edit
    # any institution.
    institution = Institution.find(params[:id])
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
