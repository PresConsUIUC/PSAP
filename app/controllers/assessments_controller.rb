class AssessmentsController < ApplicationController

  before_action :signed_in_user, :admin_user

  def index
    @assessments = Assessment.where(is_template: true)
  end

  def show
    @assessment = Assessment.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @assessment.is_template
  end

end
