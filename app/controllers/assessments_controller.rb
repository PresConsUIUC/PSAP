class AssessmentsController < ApplicationController

  before_action :signed_in_user, :admin_user

  def index
    @assessment = Assessment.find(1)
  end

end
