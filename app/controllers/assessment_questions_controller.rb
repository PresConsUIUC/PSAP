class AssessmentQuestionsController < ApplicationController

  before_action :signed_in_user

  ##
  # Responds to GET /formats/:id/assessment-questions to show all assessment
  # questions relevant to a format; also GET /locations/:id/assessment-questions
  # and GET /institutions/:id/assessment-questions.
  #
  def index
    if params[:format_id]
      @assessment_questions = Format.find(params[:format_id]).
          all_assessment_questions
    elsif params[:location_id]
      @assessment_questions = Assessment.find_by_key('location').
          assessment_questions
    elsif params[:institution_id]
      @assessment_questions = Assessment.find_by_key('institution').
          assessment_questions
    end
    @assessment_questions = @assessment_questions.
        where(parent_id: params[:parent_id]).
        order(:index)
    render json: @assessment_questions.to_json(
        include: [:assessment_question_options,
                  :enabling_assessment_question_options])
  end

end
