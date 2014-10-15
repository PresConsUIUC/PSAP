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
      @results = FormatInfo.basic_search(html: params[:q])
    end
    @query = params[:q].truncate(50)
  end

  ##
  # Responds to GET /format-id-guide/:category
  #
  def show
    @page = FormatInfo.find_by_format_category(params[:category])
    raise ActiveRecord::RecordNotFound unless @page
  end

end
