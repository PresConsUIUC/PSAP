class EventsController < ApplicationController

  PERMITTED_PARAMS = [:begin_date, :end_date, :level, :page]

  before_action :signed_in_user, unless: :format_atom?
  before_action :admin_user, unless: :format_atom?
  before_action :admin_user_with_key, if: :format_atom?
  before_action :set_sanitized_params

  def index
    @event_level = params[:level]
    @event_level = EventLevel::NOTICE if @event_level.nil?
    @events = Event.matching_params(params).
        paginate(page: params[:page],
                 per_page: ::Configuration.instance.results_per_page)
    @user = current_user unless @user
  end

  private

  def admin_user_with_key
    @user = User.joins('INNER JOIN roles ON users.role_id = roles.id').
        where(feed_key: params[:key]).
        where('roles.is_admin' => true).limit(1).first
    unless @user
      render status: :forbidden, plain: 'Access denied.'
      return
    end
  end

  def format_atom?
    request.format.atom?
  end

  def set_sanitized_params
    @sanitized_params = params.permit(PERMITTED_PARAMS)
  end

end
