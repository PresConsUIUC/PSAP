class LocationsController < ApplicationController

  before_action :signed_in_user
  before_action :user_of_same_institution_or_admin, only: [:new, :create,
                                                           :edit, :update,
                                                           :show, :destroy]

  def create
    @repository = Repository.find(params[:repository_id])
    command = CreateLocationCommand.new(@repository, location_params,
                                        current_user, request.remote_ip)
    @location = command.object
    @assessment_sections = Assessment.find_by_key('location').
        assessment_sections.order(:index)
    begin
      command.execute
    rescue ValidationError
      render 'new'
    rescue => e
      flash[:error] = "#{e}"
      render 'new'
    else
      flash[:success] = "Location \"#{@location.name}\" created."
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
      flash[:error] = "#{e}"
      redirect_to location
    else
      flash[:success] = "Location \"#{location.name}\" deleted."
      redirect_to location.repository
    end
  end

  def edit
    @location = Location.find(params[:id])

    @assessment_sections = Assessment.find_by_key('location').
        assessment_sections.order(:index)
  end

  def new
    @repository = Repository.find(params[:repository_id])
    @location = @repository.locations.build
    @location.temperature_range = TemperatureRange.new(min_temp_f: 0,
                                                       max_temp_f: 100,
                                                       score: 1)
    @assessment_sections = Assessment.find_by_key('location').
        assessment_sections.order(:index)
  end

  def show
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
        order(created_at: :desc)
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
      render 'edit'
    rescue => e
      flash[:error] = "#{e}"
      render 'edit'
    else
      flash[:success] = "Location \"#{@location.name}\" updated."
      redirect_to edit_location_url(@location)
    end
  end

  private

  def user_of_same_institution_or_admin
    # Normal users can only modify locations in their own institution.
    # Administrators can edit any location.
    if params[:id]
      location = Location.find(params[:id])
      repository = location.repository
    else
      repository = Repository.find(params[:repository_id])
    end
    redirect_to(root_url) unless
        repository.institution.users.include?(current_user) ||
            current_user.is_admin?
  end

  def location_params
    params.require(:location).permit(
        :name, :description, :repository,
        temperature_range_attributes: [:id, :min_temp_f, :max_temp_f, :score])
  end

end
