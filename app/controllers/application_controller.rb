class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :init
  after_action :flash_in_response_headers

  layout 'application'

  include SessionsHelper

  ##
  # Centralized index of all cookies used by the application.
  #
  class Cookies
    FIRST_SIGNIN = :first_signin
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  protected

  ##
  # Normally the flash is discarded after being added to the response headers
  # (see flash_in_response_headers). Calling this method will save it, enabling
  # it to work with redirects. (Notably, it works different than flash.keep.)
  #
  def keep_flash
    @keep_flash = true
  end

  private

  @keep_flash = false

  ##
  # Stores the flash message and type ('error' or 'success') in the response
  # headers, where they can be accessed by an ajax callback. Afterwards, the
  # "normal" flash is cleared, which prevents it from working with redirects.
  # To prevent this, a controller should call keep_flash before redirecting.
  #
  def flash_in_response_headers
    if request.xhr?
      response.headers['X-Psap-Message-Type'] = 'error' unless flash['error'].blank?
      response.headers['X-Psap-Message-Type'] = 'success' unless flash['success'].blank?
      response.headers['X-Psap-Message'] = flash['error'] unless flash['error'].blank?
      response.headers['X-Psap-Message'] = flash['success'] unless flash['success'].blank?
      flash.clear unless @keep_flash
    end
  end

  def init
    # Enables url_for to generate full URLs when used in ActionMailer
    ActionMailer::Base.default_url_options = { :host => request.host_with_port }

    # Array of all repositories associated with the current user, to appear in
    # the title menu.
    @user_institution_repositories =
        (current_user and current_user.institution) ?
        current_user.institution.repositories.order(:name) : []
    @user = current_user
  end

  def admin_user
    unless current_user.is_admin?
      flash['error'] = 'Access denied.'
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
