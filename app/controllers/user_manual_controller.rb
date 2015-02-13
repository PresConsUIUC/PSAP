class UserManualController < ApplicationController

  def index
  end

  ##
  # Responds to GET /manual/:category
  #
  def show
    @page = StaticPage.where(component: StaticPage::COMPONENT_USER_MANUAL,
                             uri_fragment: params[:category]).first
    raise ActiveRecord::RecordNotFound unless @page
  end

end
