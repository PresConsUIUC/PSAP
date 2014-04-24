class AssessmentSectionsController < ApplicationController

  before_action :signed_in_user, :admin_user

  def create
    command = CreateAssessmentSectionCommand.new(assessment_section_params,
                                                 current_user,
                                                 request.remote_ip)
    @assessment_section = command.object
    begin
      command.execute
      flash[:success] = "Assessment section \"#{@assessment_section.name}\" "\
      "created."
      redirect_to @assessment_section.assessment
    rescue
      render 'new'
    end
  end

  def destroy
    @assessment_section = AssessmentSection.find(params[:id])
    command = DeleteAssessmentSectionCommand.new(@assessment_section,
                                                 current_user,
                                                 request.remote_ip)
    begin
      command.execute
      flash[:success] = "Assessment section \"#{@assessment_section.name}\" "\
      "deleted."
    rescue => e
      flash[:error] = "#{e}"
    ensure
      redirect_to @assessment_section.assessment
    end
  end

  def edit
    @assessment_section = AssessmentSection.find(params[:id])
  end

  def new
    @assessment_section = AssessmentSection.new
  end

  def update
    @assessment_section = AssessmentSection.find(params[:id])
    command = UpdateAssessmentSectionCommand.new(@assessment_section,
                                                 assessment_section_params,
                                                 current_user,
                                                 request.remote_ip)
    begin
      command.execute
      flash[:success] = "Assessment section \"#{@assessment_section.name}\" "\
      "updated."
      redirect_to @assessment_section.assessment
    rescue
      render 'edit'
    end
  end

  private

  def assessment_section_params
    params.require(:assessment_section).permit(:assessment_id, :index, :name)
  end

end
