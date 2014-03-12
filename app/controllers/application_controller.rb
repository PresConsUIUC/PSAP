class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :init

  layout 'application'

  include SessionsHelper

  private
  def init
    # Array of all repositories associated with the current user, to appear in
    # the title menu.

    @user_institution_repositories = current_user ?
        current_user.institution.repositories.order(:name) : []
  end

end
