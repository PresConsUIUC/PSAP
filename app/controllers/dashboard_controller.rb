class DashboardController < ApplicationController

  before_action :signed_in_user, unless: :format_atom?

  def index
    respond_to do |format|
      format.html {
        @user = current_user
        @resources = current_user.resources.order(:name)

        if @user.institution
          @institution_users = @user.institution.users.
              where('id not in (?)', @user.id).order(:last_name)
          @recent_assessments = Resource.
              joins(:location => { :repository => :institution }).
              where(:institutions => { :id => @user.institution.id }).
              order(:updated_at => :desc).limit(5)
        else
          @institution_users = nil
          @recent_assessments = nil
        end
      }
      format.atom {
        @user = User.find_by_feed_key params[:key]
        if @user
          if @user.institution
            # array of generic event hashes
            @events = events_for_user @user
          else
            @events = []
          end
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

  def events_for_user(user)
    limit = 20
    events = []

    # user's recent assessments
    recent_assessments = Resource.
        joins(location: { repository: :institution }).
        where(institutions: { id: user.institution.id }).
        order(updated_at: :desc).limit(limit)
    recent_assessments.each do |assessment|
      events << {
          id: "tag:#{request.host}:#{request.fullpath}:assessment:#{assessment.id}",
          description: "Updated resource assessment \"#{assessment.name}\"",
          timestamp: assessment.updated_at,
          summary: "Updated resource assessment \"#{assessment.name}\"",
          user: user
      }
    end

    # users who recently joined the same institution
    recent_users = User.
        where(institution_id: @user.institution.id).
        order(created_at: :desc).limit(limit)
    recent_users.each do |user|
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

    events.sort! { |a, b| b[:timestamp] <=> a[:timestamp] }
    events[0..limit]
  end

end
