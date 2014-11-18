class HelpController < ApplicationController

  ##
  # Responds to GET /help/:category
  #
  def show
    @page = StaticPage.where(category: 'help').
        where(uri_fragment: params[:category]).first
    raise ActiveRecord::RecordNotFound unless @page
  end

end
