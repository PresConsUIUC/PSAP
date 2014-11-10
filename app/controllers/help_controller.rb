class HelpController < ApplicationController

  ##
  # Responds to GET /help
  #
  def index
  end

  ##
  # Responds to GET /help/search?q=...
  #
  def search
    @results = []
    if params[:q] and params[:q].length > 0
      @results = StaticPage.full_text_search(params[:q], %w(help))
    end
    @query = params[:q].truncate(50)
    @results_summary = @query.length > 0 ?
        "Results for \"#{@query}\"" : "Search Help"
  end

  ##
  # Responds to GET /help/:category
  #
  def show
    @page = StaticPage.find_by_uri_fragment(params[:category])
    raise ActiveRecord::RecordNotFound unless @page
  end

end
