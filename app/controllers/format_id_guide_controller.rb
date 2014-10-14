class FormatIdGuideController < ApplicationController

  ##
  # Responds to GET /format-id-guide
  #
  def index
  end

  ##
  # Responds to GET /format-id-guide/:category
  #
  def category_index
    @formats = FormatInfo.where('LOWER(format_category) LIKE ?',
                                params[:category].gsub('-', ' ').downcase)
    raise ActiveRecord::RecordNotFound unless @formats.any?
    @category = @formats[0].format_category
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

end
