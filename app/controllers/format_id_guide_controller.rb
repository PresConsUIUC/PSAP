class FormatIdGuideController < ApplicationController

  def index
  end

  def category_index
    @formats = FormatInfo.where('LOWER(format_category) LIKE ?', params[:category].gsub('-', ' ').downcase)
    raise ActiveRecord::RecordNotFound unless @formats.any?
    @category = @formats[0].format_category
  end

end
