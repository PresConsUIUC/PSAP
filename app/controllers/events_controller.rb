class EventsController < ApplicationController

  before_action :signed_in_user, unless: :format_atom?
  before_action :admin_user, unless: :format_atom?
  before_action :admin_user_with_key, if: :format_atom?

  def index
    q = "%#{params[:q]}%"
    @event_level = params[:level]
    @event_level = EventLevel::INFO if @event_level.nil?

    @events = Event.joins('LEFT JOIN users ON users.id = events.user_id').
        where('events.description LIKE ? OR users.username LIKE ? OR events.address LIKE ?', q, q, q).
        where('events.event_level <= ?', @event_level).
        order(created_at: :desc).paginate(page: params[:page], per_page: 100)
    @user = current_user unless @user
  end

  def admin_user_with_key
    @user = User.joins('INNER JOIN roles ON users.role_id = roles.id').
        where(feed_key: params[:key]).
        where('roles.is_admin' => true).limit(1).first
    unless @user
      render status: :forbidden, text: 'Access denied.'
      return
    end
  end

  def format_atom?
    request.format.atom?
  end

end
