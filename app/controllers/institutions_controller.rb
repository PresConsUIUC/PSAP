class InstitutionsController < ApplicationController

  before_action :signed_in_user
  before_action :before_new_action, only: [:new, :create]
  before_action :before_edit_action, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def create
    @institution = Institution.new(institution_params)
    if @institution.save
      flash[:success] = 'Institution created.'
      redirect_to @institution
    else
      render 'new'
    end
  end

  def destroy
  end

  def edit
    @institution = Institution.find(params[:id])
  end

  def index
    @institutions = Institution.order(:name).paginate(page: params[:page],
                                                      per_page: 30)
  end

  def new
    @institution = Institution.new
  end

  def show
    @institution = Institution.find(params[:id])
  end

  def update
    @institution = Institution.find(params[:id])
    if @institution.update_attributes(institution_params)
      flash[:success] = 'Institution updated.'
      redirect_to @institution
    else
      render 'edit'
    end
  end

  private

  def before_edit_action
    # Normal users can only edit their own institution. Administrators can edit
    # any institution.
    institution = Institution.find(params[:id])
    redirect_to(root_url) unless
        institution.users.include?(current_user) || current_user.is_admin?
  end

  def before_new_action
    # Normal users can't create new institutions (this is done during the user
    # signup phase), but administrators can.
    redirect_to(root_url) unless current_user.is_admin?
  end

  def institution_params
    params.require(:institution).permit(:name)
  end

end
