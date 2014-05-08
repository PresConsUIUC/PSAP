class DashboardController < ApplicationController

  before_action :signed_in_user, unless: :format_atom?

  def index
    respond_to do |format|
      format.html {
        limit = 5
        @user = current_user
        @resources = current_user.resources.order(:name)
        @user_events = Event.where(user: @user).order(created_at: :desc).
            limit(limit)

        if @user.institution
          @institution_events = Event.
              joins('LEFT JOIN users ON users.id = events.user_id').
              joins('LEFT JOIN institutions ON users.institution_id = institutions.id').
              where('users.institution_id' => @user.id).
              order(created_at: :desc).limit(limit)
          @institution_users = @user.institution.users.
              where('id != ?', @user.id).order(:last_name)
          @recent_assessments = Resource.
              joins(:location => { :repository => :institution }).
              where(:institutions => { :id => @user.institution.id }).
              order(:updated_at => :desc).limit(limit)
        else
          @institution_events = []
          @institution_users = []
          @recent_assessments = []
          render 'welcome'
        end
      }
      format.atom {
        limit = 20
        @user = User.find_by_feed_key params[:key]
        if @user
          @events = @user.institution ? all_events_for_user(@user, limit) : []
        else
          render status: :forbidden, text: 'Access denied.'
          return
        end
      }
    end
  end

  private

  def format_atom?
    request.format.atom?
  end

  def recent_assessments_by_user(user, limit)
    events = []
    assessments = Resource.
        joins(location: { repository: :institution }).
        where(institutions: { id: user.institution.id }).
        order(updated_at: :desc).limit(limit)
    assessments.each do |assessment|
      events << {
          id: "tag:#{request.host}:#{request.fullpath}:assessment:#{assessment.id}",
          description: "Updated resource assessment \"#{assessment.name}\"",
          timestamp: assessment.updated_at,
          summary: "Updated resource assessment \"#{assessment.name}\"",
          user: user
      }
    end
    events
  end

  def recent_assessments_in_same_institution(user, limit)
    events = []
    assessments = Resource.
        joins(location: { repository: :institution }).
        where(institutions: { id: user.institution.id }).
        order(updated_at: :desc).limit(limit)
    assessments.each do |assessment|
      events << {
          id: "tag:#{request.host}:#{request.fullpath}:assessment:#{assessment.id}",
          description: "Updated resource assessment \"#{assessment.name}\"",
          timestamp: assessment.updated_at,
          summary: "Updated resource assessment \"#{assessment.name}\"",
          user: user
      }
    end
    events
  end

  def recent_users_in_same_institution(user, limit)
    events = []
    users = User.
        where(institution_id: @user.institution.id).
        order(created_at: :desc).limit(limit)
    users.each do |user|
      events << {
          id: "tag:#{request.host}:#{request.fullpath}:user:#{user.username}",
          description: "New user at #{user.institution.name}: "\
                  "#{user.full_name}",
          timestamp: user.created_at,
          summary: "New user at #{user.institution.name}: "\
                  "#{user.full_name}",
          user: user
      }
    end
    events
  end

  # Returns an array of generic event hashes.
  def all_events_for_user(user, limit)
    events = []
    events.concat recent_assessments_in_same_institution(user, limit)
    events.concat recent_assessments_by_user(user, limit)
    events.concat recent_users_in_same_institution(user, limit)
    events.sort! { |a, b| b[:timestamp] <=> a[:timestamp] }
    events[0..limit]
  end

end
