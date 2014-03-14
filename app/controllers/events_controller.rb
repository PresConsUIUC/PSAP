class EventsController < ApplicationController

  before_action :admin_user

  def index
    @events = Event.order(created_at: :desc).paginate(page: params[:page],
                                                      per_page: 100)
  end

end
