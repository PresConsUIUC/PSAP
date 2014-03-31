class DashboardController < ApplicationController

  before_action :signed_in_user

  def index
    @user = current_user
    @institution_users = @user.institution ?
        @user.institution.users.where('id not in (?)', @user.id).order(:last_name) :
        nil
  end

end
