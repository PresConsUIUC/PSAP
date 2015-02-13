class FormatIdGuideController < ApplicationController

  ##
  # Responds to GET /format-id-guide
  #
  def index
  end

  ##
  # Responds to GET /format-id-guide/search?q=...
  #
  def search
    @results = []
    if params[:q] and params[:q].length > 0
      @results = StaticPage.full_text_search(
          params[:q], StaticPage::COMPONENT_FORMAT_ID_GUIDE)
    end
    @query = params[:q].truncate(50)
    @results_summary = @query.length > 0 ?
        "Results for \"#{@query}\"" : "Format ID Guide Search"
  end

  ##
  # Responds to GET /format-id-guide/:category
  #
  def show
    @page = StaticPage.where(component: StaticPage::COMPONENT_FORMAT_ID_GUIDE,
                             uri_fragment: params[:category]).first
    raise ActiveRecord::RecordNotFound unless @page
  end

end
