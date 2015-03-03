class HelpController < ApplicationController

  def index
  end

  ##
  # Responds to GET /help/:category
  #
  def show
    @page = StaticPage.where(component: StaticPage::COMPONENT_HELP,
                             uri_fragment: params[:category]).first
    raise ActiveRecord::RecordNotFound unless @page
  end

end
