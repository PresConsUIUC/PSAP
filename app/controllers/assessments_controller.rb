class AssessmentsController < ApplicationController

  before_action :signed_in_user, :admin_user

  def edit
    @assessment = Assessment.find(1)
  end

  def index
    @assessment = Assessment.find(1)
  end

  def update
    @assessment = Assessment.find(1)
    command = UpdateAssessmentCommand.new(@assessment, assessment_params,
                                          current_user, request.remote_ip)
    begin
      command.execute
      flash[:success] = 'Assessment updated.'
      redirect_to @assessment
    rescue
      render 'edit'
    end
  end

  private

  def assessment_params
    params.require(:assessment).permit(:assessment_section)
  end

end
