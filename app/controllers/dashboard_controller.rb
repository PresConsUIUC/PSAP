class DashboardController < ApplicationController

  before_action :signed_in_user

  def index
    @user = current_user

    @assessments = current_user.resources.order(:name)

    if @user.institution
      @institution_users = @user.institution.users.
          where('id not in (?)', @user.id).order(:last_name)
      @recent_assessments = Resource.joins(:location => { :repository => :institution }).
          where(:institutions => { :id => @user.institution.id }).
          order(:created_at => :desc).limit(5)
    else
      @institution_users = nil
      @recent_assessments = nil
    end
  end

end
