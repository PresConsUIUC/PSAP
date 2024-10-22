class InstitutionsController < ApplicationController

  before_action :signed_in_user
  before_action :admin_user, only: [:index, :destroy]
  before_action :same_institution_user, except: [:create, :destroy, :index,
                                                 :new]

  def assess
    if request.xhr?
      @institution = Institution.find(params[:institution_id])
      @assessment_sections = Assessment.find_by_key('institution').
          assessment_sections.order(:index)
      render partial: 'assess_form', locals: { action: :assess }
    else
      render status: 406, plain: 'Not Acceptable'
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
      render status: 406, plain: 'Not Acceptable'
    end
  end

  def export
    institution = Institution.find(params[:institution_id])
    send_data JSON.pretty_generate(institution.full_export_as_json),
              type:        'application/json',
              filename:    'full_export.json',
              disposition: 'attachment'
  end

  def index
    prepare_index_view
  end

  def new
    if request.xhr?
      @institution = Institution.new
      render partial: 'edit_form', locals: { action: :create }
    else
      render status: 406, plain: 'Not Acceptable'
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
        per_page: ::Configuration.instance.results_per_page)
  end

  def prepare_show_view
    @institution = Institution.find(params[:id])

    # data for repositories tab
    @repositories = @institution.repositories.order(:name).
        paginate(page: params[:page],
                 per_page: ::Configuration.instance.results_per_page)

    # data for users tab
    @institution_users = @institution.users.where(confirmed: true).order(:last_name)
  end

  def same_institution_user
    # Normal users can only edit their own institution. Administrators can edit
    # any institution.
    institution = Institution.find(params[:id] || params[:institution_id])
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
