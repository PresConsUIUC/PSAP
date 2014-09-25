class AssessmentQuestionsController < ApplicationController

  before_action :signed_in_user
  before_action :admin_user, except: :index

  def create
    command = CreateAssessmentQuestionCommand.new(assessment_question_params,
                                                  current_user,
                                                  request.remote_ip)
    @assessment_question = command.object
    begin
      command.execute
    rescue ValidationError
      render 'edit'
    rescue => e
      flash[:error] = "#{e}"
      render 'new'
    else
      flash[:success] = 'Assessment question created.'
      redirect_to assessments_url
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

  ##
  # Responds to /formats/:id/assessment-questions to show all assessment
  # questions relevant to a format.
  #
  def index
    @assessment_questions = Format.find(params[:format_id]).
        all_assessment_questions.
        where(parent_id: params[:parent_id]). # AQ parent id, not format
        order(:index)
    render json: @assessment_questions.to_json(
        include: [:assessment_question_options,
                  :enabling_assessment_question_options])
  end

  def new
    @assessment_question = AssessmentQuestion.new
    @assessment_question.assessment_question_options <<
        AssessmentQuestionOption.new(name: 'Sample Option', index: 0, value: 1,
                                     assessment_question: @assessment_question)
    if params[:assessment_key]
      @assessment = Assessment.find_by_key(params[:assessment_key])
    else
      @assessment = AssessmentSection.find(params[:assessment_section_id]).assessment
    end
  end

  def update
    @assessment_question = AssessmentQuestion.find(params[:id])
    command = UpdateAssessmentQuestionCommand.new(@assessment_question,
                                                  assessment_question_params,
                                                  current_user,
                                                  request.remote_ip)
    begin
      command.execute
    rescue ValidationError
      render 'edit'
    rescue => e
      flash[:error] = "#{e}"
      render 'edit'
    else
      flash[:success] = 'Assessment question updated.'
      redirect_to assessments_url
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
                                                ],
                                                formats_attributes: [
                                                    :id
                                                ])
  end

end
