class LocationsController < ApplicationController

  before_action :signed_in_user
  before_action :user_of_same_institution_or_admin,
                only: [:assess, :create, :destroy, :edit, :new, :show, :update]

  def assess
    if request.xhr?
      @location = Location.find(params[:location_id])
      @assessment_sections = Assessment.find_by_key('location').
          assessment_sections.order(:index)
      render partial: 'assess_form', locals: { action: :assess }
    else
      render status: 406, plain: 'Not Acceptable'
    end
  end

  def create
    @repository = Repository.find(params[:repository_id])
    command = CreateLocationCommand.new(@repository, location_params,
                                        current_user, request.remote_ip)
    @location = command.object
    begin
      command.execute
    rescue ValidationError
      response.headers['X-Psap-Result'] = 'error'
      render partial: 'shared/validation_messages',
             locals: { entity: @location }
    rescue => e
      response.headers['X-Psap-Result'] = 'error'
      flash['error'] = "#{e}"
      keep_flash
      render 'create'
    else
      response.headers['X-Psap-Result'] = 'success'
      flash['success'] = "Location \"#{@location.name}\" created."
      keep_flash
      render 'create'
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
      render partial: 'edit_form', locals: { action: :edit }
    else
      render status: 406, plain: 'Not Acceptable'
    end
  end

  def new
    if request.xhr?
      @repository = Repository.find(params[:repository_id])
      @location = @repository.locations.build
      render partial: 'edit_form', locals: { action: :create }
    else
      render status: 406, plain: 'Not Acceptable'
    end
  end

  def show
    prepare_show_view
  end

  def update
    @location = Location.find(params[:id])
    command = UpdateLocationCommand.new(@location, location_params,
                                        current_user, request.remote_ip)
    begin
      command.execute
    rescue ValidationError
      response.headers['X-Psap-Result'] = 'error'
      render partial: 'shared/validation_messages',
             locals: { entity: @location }
    rescue => e
      response.headers['X-Psap-Result'] = 'error'
      flash['error'] = "#{e}"
      prepare_show_view
      render 'show'
    else
      response.headers['X-Psap-Result'] = 'success'
      flash['success'] = "Location \"#{@location.name}\" updated."
      prepare_show_view
      render 'show'
    end
  end

  private

  def prepare_show_view
    @location = Location.find(params[:id])
    # show only top-level resources
    @resources = @location.resources.where(parent_id: nil).order(:name).
        paginate(page: params[:page],
                 per_page: ::Configuration.instance.results_per_page)
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
        repository.institution.users.include?(current_user) or
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
