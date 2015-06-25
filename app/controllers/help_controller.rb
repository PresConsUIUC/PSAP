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
    @page = StaticPage.where(component: StaticPage::Component::HELP,
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
    @page = StaticPage.
        where(component: StaticPage::Component::USER_MANUAL).first
    raise ActiveRecord::RecordNotFound unless @page
  end

  ##
  # Responds to GET /search?q=...
  #
  def search
    @results = []
    if params[:q] and params[:q].length > 0
      @results = StaticPage.full_text_search(
          params[:q],
          [StaticPage::Component::HELP, StaticPage::Component::USER_MANUAL])
    end
    @query = params[:q].truncate(50)
    @results_summary = @query.length > 0 ?
        "Results for \"#{@query}\"" : "Help Search"
  end

  ##
  # Responds to GET /simple-help
  #
  def simple_index
  end

end
