class AssessmentsController < ApplicationController

  before_action :signed_in_user, :admin_user

  def index
    @assessments = Assessment.where(is_template: true).order(:name)
  end

  def show
    @assessment = Assessment.find_by_key(params[:key])
    raise ActiveRecord::RecordNotFound unless @assessment &&
        @assessment.is_template
  end

end
