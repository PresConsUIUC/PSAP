class DashboardController < ApplicationController

  before_action :signed_in_user

  def index
    @user = current_user

    respond_to do |format|
      format.html {
        @resources = current_user.resources.order(:name)

        if @user.institution
          @institution_users = @user.institution.users.
              where('id not in (?)', @user.id).order(:last_name)
          @recent_assessments = Resource.joins(:location => { :repository => :institution }).
              where(:institutions => { :id => @user.institution.id }).
              order(:updated_at => :desc).limit(5)
        else
          @institution_users = nil
          @recent_assessments = nil
        end
      }
      format.atom {
        @events = []
        if @user.institution
          recent_assessments = Resource.joins(:location => { :repository => :institution }).
              where(:institutions => { :id => @user.institution.id }).
              order(:updated_at => :desc).limit(20)
          recent_assessments.each do |assessment|
            @events << {
                id: "tag:#{request.host}:#{request.fullpath}:assessment_#{assessment.id}",
                description: assessment.name,
                timestamp: assessment.updated_at,
                summary: assessment.name,
                user: @user
            }
          end
          @events.sort! { |a, b| b[:timestamp] <=> a[:timestamp] }
        end
      }
    end
  end

end
