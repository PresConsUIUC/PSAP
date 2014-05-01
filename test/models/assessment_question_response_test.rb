require 'test_helper'

class AssessmentQuestionResponseTest < ActiveSupport::TestCase

  def setup
    @response = assessment_question_responses(:assessment_question_response_one)
  end

  ############################ object tests #################################

  test 'valid response saves' do
    assert @response.save
  end

  ########################### property tests ################################

  # assessment_question
  test 'assessment_question is required' do
    @response.assessment_question = nil
    assert !@response.save
  end

  # resource
  test 'resource is required' do
    @response.resource = nil
    assert !@response.save
  end

end
