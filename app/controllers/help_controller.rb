class HelpController < ApplicationController

  ##
  # Responds to GET /advanced-help
  #
  def advanced_index
  end

  ##
  # Responds to GET /advanced-help/:category
  #
  def advanced_show
    @page = StaticPage.where(component: StaticPage::COMPONENT_HELP,
                             uri_fragment: params[:category]).first
    raise ActiveRecord::RecordNotFound unless @page
  end

  ##
  # Main help landing page. Responds to GET /help
  #
  def index
  end

  ##
  # Responds to GET /manual
  #
  def manual
    # there is only one user manual page
    @page = StaticPage.where(component: StaticPage::COMPONENT_USER_MANUAL).first
    raise ActiveRecord::RecordNotFound unless @page
  end

  ##
  # Responds to GET /simple-help
  #
  def simple_index
  end

end
