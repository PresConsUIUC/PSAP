class DashboardController < ApplicationController

  before_action :signed_in_user, unless: :format_atom?

  def index
    respond_to do |format|
      format.html do
        limit = 4
        @user = current_user
        @user_events = Event.where(user: @user).order(created_at: :desc).limit(limit)

        if @user.is_admin?
          @most_active_users = User.most_active(limit)
          @most_active_institutions = Institution.most_active(limit)
        end
        if @user.institution
          @most_active_institution_users = @user.institution.most_active_users(limit)
          @institution_events = events_for_institution(@user, limit)
          @institution_users = @user.institution.users.
              where('id != ?', @user.id).order(:last_name)
          @recent_updated_resources = Resource.
              joins(:location => { :repository => :institution }).
              where(:institutions => { :id => @user.institution.id }).
              order(:updated_at => :desc).limit(limit)
        else
          @institutions = Institution.all.order(:name)
          render 'unaffiliated'
        end
      end
      format.atom do
        limit = 20
        @user = User.find_by_feed_key params[:key]
        if @user
          @events = @user.institution ? events_for_institution(@user, limit) : []
        else
          render status: :forbidden, text: 'Access denied.'
        end
      end
    end
  end

  private

  def format_atom?
    request.format.atom?
  end

  # Returns an array of generic event hashes.
  def events_for_institution(user, limit)
    events = Event.
        joins('LEFT JOIN users ON users.id = events.user_id').
        joins('LEFT JOIN institutions ON users.institution_id = institutions.id').
        where('users.institution_id' => user.id).
        order(created_at: :desc).limit(limit)
    events
  end

end
