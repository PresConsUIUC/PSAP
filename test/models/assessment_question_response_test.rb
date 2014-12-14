require 'test_helper'

class AssessmentQuestionResponseTest < ActiveSupport::TestCase

  def setup
    @response = assessment_question_responses(:assessment_question_response_one)
  end

  ######################### class method tests ##############################

  # none

  ############################ object tests #################################

  test 'valid response saves' do
    @response.resource = resources(:resource_one)
    assert @response.save
  end

  ########################### property tests ################################

  # assessment_question
  test 'assessment_question is required' do
    @response.assessment_question = nil
    assert !@response.save
  end

  ############################ method tests #################################

  # none

  ########################## association tests ##############################

  test 'must belong to either an institution, location, or resource' do
    @response.institution = @response.location = @response.resource = nil
    assert !@response.save
  end

  test 'can belong to an institution' do
    @response.institution = institutions(:institution_one)
    assert @response.save
  end

  test 'can belong to a location' do
    @response.location = locations(:location_one)
    assert @response.save
  end

  test 'can belong to a resource' do
    @response.resource = resources(:resource_one)
    assert @response.save
  end

end
