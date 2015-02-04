class StaticController < ApplicationController

  before_action :signed_in_user, only: :landing

  def about
  end

  def bibliography
  end

  def glossary
  end

  def landing
  end

  # Overrides parent
  def signed_in_user
    redirect_to dashboard_url if signed_in?
  end

end
