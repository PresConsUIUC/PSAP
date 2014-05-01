class EventsController < ApplicationController

  before_action :signed_in_user, :admin_user

  def index
    q = "%#{params[:q]}%"
    @events = Event.joins('LEFT JOIN users ON users.id = events.user_id').where(
        'events.description LIKE ? OR users.username LIKE ? OR events.address LIKE ?', q, q, q).
        order(created_at: :desc).paginate(page: params[:page], per_page: 100)
    @user = current_user
  end

end
