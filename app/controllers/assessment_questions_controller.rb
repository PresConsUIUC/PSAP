class AssessmentQuestionsController < ApplicationController

  before_action :signed_in_user, :admin_user

  def create
    command = CreateAssessmentQuestionCommand.new(assessment_question_params,
                                                  current_user,
                                                  request.remote_ip)
    @assessment_question = command.object
    begin
      command.execute
      flash[:success] = 'Assessment question created.'
      redirect_to assessments_url
    rescue
      render 'new'
    end
  end

  def destroy
    @assessment_question = AssessmentQuestion.find(params[:id])
    command = DeleteAssessmentQuestionCommand.new(@assessment_question,
                                                  current_user,
                                                  request.remote_ip)
    begin
      command.execute
      flash[:success] = 'Assessment question deleted.'
    rescue => e
      flash[:error] = "#{e}"
    ensure
      redirect_to assessments_url
    end
  end

  def edit
    @assessment_question = AssessmentQuestion.find(params[:id])
  end

  def new
    @assessment_question = AssessmentQuestion.new
    @assessment_question.assessment_question_options <<
        AssessmentQuestionOption.new(name: 'Sample Option', index: 0, value: 1,
                                     assessment_question: @assessment_question)
  end

  def update
    @assessment_question = AssessmentQuestion.find(params[:id])
    command = UpdateAssessmentQuestionCommand.new(@assessment_question,
                                                  assessment_question_params,
                                                  current_user,
                                                  request.remote_ip)
    begin
      command.execute
      flash[:success] = 'Assessment question updated.'
      redirect_to assessments_url
    rescue
      render 'edit'
    end
  end

  private

  def assessment_question_params
    params.require(:assessment_question).permit(:assessment_section_id, :index,
                                                :name, :parent_id,
                                                :question_type, :weight,
                                                assessment_question_options_attributes: [
                                                    :id, :name, :value, :index,
                                                    :_destroy
                                                ])
  end

end
