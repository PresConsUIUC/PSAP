class AssessmentsController < ApplicationController

  before_action :signed_in_user, :admin_user

  def index
    @assessments = Assessment.all
  end

  def show
    @assessment = Assessment.find(params[:id])
  end

end
