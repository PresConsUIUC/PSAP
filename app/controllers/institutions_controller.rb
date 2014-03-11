class InstitutionsController < ApplicationController

  before_action :signed_in_user
  before_action :correct_user, only: [:edit, :update]
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
    flash[:notice] = 'Institutions cannot be deleted.'
    redirect_to institutions_url
  end

  def edit
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

  def institution_params
    params.require(:institution).permit(:name)
  end

  def admin_user
    redirect_to(root_url) unless current_user.role.is_admin?
  end

  def signed_in_user
    unless signed_in?
      store_location
      redirect_to login_url, notice: 'Please sign in.'
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

end
