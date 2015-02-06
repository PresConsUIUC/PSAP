class LocationsController < ApplicationController

  before_action :signed_in_user
  before_action :user_of_same_institution_or_admin,
                only: [:assess, :create, :destroy, :edit, :new, :show, :update]

  def assess
    @location = Location.find(params[:location_id])
    @assessment_sections = Assessment.find_by_key('location').
        assessment_sections.order(:index)
  end

  def create
    @repository = Repository.find(params[:repository_id])
    command = CreateLocationCommand.new(@repository, location_params,
                                        current_user, request.remote_ip)
    @location = command.object
    begin
      command.execute
    rescue ValidationError
      render 'new'
    rescue => e
      flash['error'] = "#{e}"
      render 'new'
    else
      flash['success'] = "Location \"#{@location.name}\" created."
      redirect_to @location
    end
  end

  def destroy
    location = Location.find(params[:id])
    command = DeleteLocationCommand.new(location, current_user,
                                        request.remote_ip)
    begin
      command.execute
    rescue => e
      flash['error'] = "#{e}"
      redirect_to location
    else
      flash['success'] = "Location \"#{location.name}\" deleted."
      redirect_to location.repository
    end
  end

  def edit
    if request.xhr?
      @location = Location.find(params[:id])
      render partial: 'edit_form'
    end
  end

  def new
    @repository = Repository.find(params[:repository_id])
    @location = @repository.locations.build
    @assessment_sections = Assessment.find_by_key('location').
        assessment_sections.order(:index)
  end

  def show
    prepare_show_view
  end

  def update
    @location = Location.find(params[:id])
    command = UpdateLocationCommand.new(@location, location_params,
                                        current_user, request.remote_ip)
    @assessment_sections = Assessment.find_by_key('location').
        assessment_sections.order(:index)
    begin
      command.execute
    rescue ValidationError
      response.headers['X-Psap-Result'] = 'error'
      render partial: 'shared/validation_messages',
             locals: { entity: @location }
    rescue => e
      response.headers['X-Psap-Result'] = 'error'
      flash['error'] = "#{e}"
      render 'show'
    else
      prepare_show_view
      response.headers['X-Psap-Result'] = 'success'
      flash['success'] = "Location \"#{@location.name}\" updated."
      render 'show'
    end
  end

  private

  def prepare_show_view
    @location = Location.find(params[:id])
    # show only top-level resources
    @resources = @location.resources.where(parent_id: nil).order(:name).
        paginate(page: params[:page],
                 per_page: Psap::Application.config.results_per_page)
    @assessment_sections = Assessment.find_by_key('location').
        assessment_sections.order(:index)
    @events = Event.joins('LEFT JOIN events_locations ON events_locations.event_id = events.id').
        joins('LEFT JOIN events_resources ON events_resources.event_id = events.id').
        where('events_locations.location_id IN (?) '\
        'OR events_resources.resource_id IN (?)',
              @location.id,
              @location.resources.map{ |res| res.id }).
        order(created_at: :desc).
        limit(20)
  end

  def user_of_same_institution_or_admin
    # Normal users can only modify locations in their own institution.
    # Administrators can edit any location.
    if params[:id]
      location = Location.find(params[:id])
      repository = location.repository
    elsif params[:location_id]
      location = Location.find(params[:location_id])
      repository = location.repository
    elsif params[:repository_id]
      repository = Repository.find(params[:repository_id])
    end
    redirect_to(root_url) unless
        repository.institution.users.include?(current_user) ||
            current_user.is_admin?
  end

  def location_params
    params.require(:location).permit(:name, :description, :repository)
        .tap do |whitelisted|
      # AQRs don't use Rails' nested params format, and will require additional
      # processing
      whitelisted[:assessment_question_responses] =
          params[:location][:assessment_question_responses] if
          params[:location][:assessment_question_responses]
    end
  end

end
