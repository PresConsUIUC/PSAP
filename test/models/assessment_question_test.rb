require 'test_helper'

class AssessmentQuestionTest < ActiveSupport::TestCase

  def setup
    @question = assessment_questions(:assessment_question_one)
  end

  ######################### class method tests ##############################

  # none

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

  # qid
  test 'qid is required' do
    @question.qid = nil
    assert !@question.save
  end

  # question_type
  test 'question_type is required' do
    @question.question_type = nil
    assert !@question.save
  end

  test 'question_type should be valid' do
    @question.question_type = 8
    assert !@question.save
  end

  # weight
  test 'weight is required' do
    @question.weight = nil
    assert !@question.save
  end

  test 'weight should be greater than 0' do
    @question.weight = -0.5
    assert !@question.save
    @question.weight = 0.5
    assert @question.save
  end

  ############################ method tests #################################

  # max_score
  test 'max_score should return the correct score' do
    assert_equal 1, @question.max_score
  end

  ########################### association tests ##############################

  test 'dependent assessment question options should be destroyed on destroy' do
    option = assessment_question_options(:assessment_question_option_one)
    @question.assessment_question_options << option
    @question.destroy
    assert option.destroyed?
  end

  test 'dependent assessment question responses should be destroyed on destroy' do
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
