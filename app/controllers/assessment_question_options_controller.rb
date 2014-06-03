class AssessmentQuestionOptionsController < ApplicationController

  before_action :signed_in_user, :admin_user

  # Responds to /assessment-questions/:id/options in order to facilitate
  # dependent select menus in the assessment template forms
  # (/assessment-questions/:id/new or edit).
  def index
    question = AssessmentQuestion.find(params[:assessment_question_id])
    respond_to do |format|
      format.json { render json: question.assessment_question_options }
    end
  end

end
