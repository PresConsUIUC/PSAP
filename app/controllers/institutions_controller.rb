class InstitutionsController < ApplicationController

  before_action :signed_in_user
  before_action :admin_user, only: [:index, :destroy]
  before_action :same_institution_user, only: [:show, :edit, :update]

  def create
    command = CreateInstitutionCommand.new(
        institution_params,
        current_user)
    @institution = command.object
    begin
      command.execute
      flash[:success] = "The institution \"#{@institution.name}\" has been "\
        "created, and you have automatically been added to it."
      redirect_to @institution
    rescue
      render 'new'
    end
  end

  def destroy
    @institution = Institution.find(params[:id])
    command = DeleteInstitutionCommand.new(@institution, current_user)
    begin
      command.execute
      flash[:success] = "Institution \"#{@institution.name}\" deleted."
    rescue => e
      flash[:error] = "#{e}"
    ensure
      redirect_to institutions_url
    end
  end

  def edit
    @institution = Institution.find(params[:id])
  end

  def index
    @institutions = Institution.order(:name).paginate(page: params[:page],
                                                      per_page: 50)
  end

  def new
    @institution = Institution.new
  end

  def show
    @institution = Institution.find(params[:id])
    @institution_users = @institution.users.where(confirmed: true).order(:last_name)
    # show only top-level resources
    @resources = @institution.resources.where(parent_id: nil).order(:name) # TODO: pagination
  end

  def update
    @institution = Institution.find(params[:id])
    command = UpdateInstitutionCommand.new(@institution, institution_params,
                                           current_user)
    begin
      command.execute
      flash[:success] = "Institution \"#{@institution.name}\" updated."
      redirect_to @institution
    rescue
      render 'edit'
    end
  end

  # Outputs a high-level assessment report as a PDF.
  def report

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
                                        :description, :email)
  end

end
