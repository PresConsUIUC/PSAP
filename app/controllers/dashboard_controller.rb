class DashboardController < ApplicationController

  before_action :signed_in_user

  def index
    @user = current_user
    @institution_users = @user.institution ?
        @user.institution.users.where('id not in (?)', @user.id).order(:last_name) :
        nil
    @assessments = current_user.resources.order(:name)
    @recent_assessments = Resource.joins(:location => { :repository => :institution }).
        where(:institutions => { :id => @user.institution.id }).
        order(:created_at => :desc).limit(5)
  end

end
