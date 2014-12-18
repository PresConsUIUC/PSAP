class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :init
  after_filter :flash_in_response_headers

  layout 'application'

  include SessionsHelper

  def sort_direction
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : 'asc'
  end

  private

  # Stores the flash message and type in the response headers for ajax
  # purposes.
  def flash_in_response_headers
    if request.xhr?
      response.headers['X-Message-Type'] = 'error' unless flash['error'].blank?
      response.headers['X-Message-Type'] = 'success' unless flash['success'].blank?
      response.headers['X-Message'] = flash['error'] unless flash['error'].blank?
      response.headers['X-Message'] = flash['success'] unless flash['success'].blank?
    end
  end

  def init
    # Enables url_for to generate full URLs when used in ActionMailer
    ActionMailer::Base.default_url_options = { :host => request.host_with_port }

    # Array of all repositories associated with the current user, to appear in
    # the title menu.
    @user_institution_repositories = current_user && current_user.institution ?
        current_user.institution.repositories.order(:name) : []
    @user = current_user
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
      redirect_to signin_url, notice: 'Please sign in.'
    end
  end

end
