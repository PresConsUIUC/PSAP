class EventsController < ApplicationController

  before_action :signed_in_user, :admin_user

  def index
    @events = Event.order(created_at: :desc).paginate(page: params[:page],
                                                      per_page: 100)
    @user = current_user
  end

end
