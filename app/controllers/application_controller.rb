class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :init

  layout 'application'

  include SessionsHelper

  private

  def init
    # Enables url_for to generate full URLs when used in ActionMailer
    ActionMailer::Base.default_url_options = { :host => request.host_with_port }

    # Array of all repositories associated with the current user, to appear in
    # the title menu.
    @user_institution_repositories = current_user ?
        current_user.institution.repositories.order(:name) : []
  end

  def admin_user
    unless current_user.is_admin?
      flash[:error] = 'Access denied.'
      redirect_to(root_url)
    end
  end

  def signed_in_user
    unless signed_in?
      store_location
      redirect_to login_url, notice: 'Please sign in.'
    end
  end

  def signed_out_user
    if signed_in?
      store_location
      redirect_to root_url, notice: 'You are already signed in.'
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

end
