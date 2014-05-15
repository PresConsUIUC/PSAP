require 'test_helper'

class AssessmentQuestionTest < ActiveSupport::TestCase

  def setup
    @question = assessment_questions(:assessment_question_one)
  end

  ############################ object tests #################################

  test 'valid question saves' do
    assert @question.save!
  end

  ########################### property tests ################################

  # assessment_section
  test 'assessment_section is required' do
    @question.assessment_section = nil
    assert !@question.save
  end

  # index
  test 'index is required' do
    @question.index = nil
    assert !@question.save
  end

  # name
  test 'name is required' do
    @question.name = nil
    assert !@question.save
  end

  # question_type
  test 'question_type is required' do
    @question.question_type = nil
    assert !@question.save
  end

  # weight
  test 'weight is required' do
    @question.weight = nil
    assert !@question.save
  end

  test 'weight should be between 0 and 1' do
    @question.weight = -0.5
    assert !@question.save
    @question.weight = 1.2
    assert !@question.save
  end

  ########################### dependency tests ###############################

  test 'dependent options should be destroyed on destroy' do
    option = assessment_question_options(:assessment_question_option_one)
    @question.assessment_question_options << option
    @question.destroy
    assert option.destroyed?
  end

  test 'dependent responses should be destroyed on destroy' do
    response = assessment_question_responses(:assessment_question_response_one)
    @question.assessment_question_responses << response
    @question.destroy
    assert response.destroyed?
  end

  test 'children should be destroyed on destroy' do
    child = assessment_questions(:assessment_question_two)
    @question.children << child
    @question.destroy
    assert child.destroyed?
  end

end
