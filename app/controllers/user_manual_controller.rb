class UserManualController < ApplicationController

  def index
  end

  ##
  # Responds to GET /manual/:category
  #
  def show
    @page = StaticPage.where(category: 'manual').
        where(uri_fragment: params[:category]).first
    raise ActiveRecord::RecordNotFound unless @page
  end

end
