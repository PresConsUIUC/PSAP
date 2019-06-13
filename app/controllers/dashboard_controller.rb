class DashboardController < ApplicationController

  before_action :signed_in_user

  def index
    limit = 4
    @user = current_user

    if @user.institution
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

end
