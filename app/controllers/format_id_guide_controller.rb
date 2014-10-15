class FormatIdGuideController < ApplicationController

  ##
  # Responds to GET /format-id-guide
  #
  def index
  end

  ##
  # Responds to /format-id-guide/search?q=...
  #
  def search
    @results = []
    if params[:q] and params[:q].length > 0
      @results = FormatInfo.where('description LIKE ?', "%#{params[:q]}%"). # TODO: use postgresql full-text search
          paginate(page: params[:page], per_page: 20)
    end
  end

  ##
  # Responds to GET /format-id-guide/:category
  #
  def show
    @page = FormatInfo.find_by_format_category(params[:category])
    raise ActiveRecord::RecordNotFound unless @page
  end

end
