require 'test_helper'

class AssessmentQuestionOptionTest < ActiveSupport::TestCase

  def setup
    @option = assessment_question_options(:one)
  end

  ######################### class method tests ##############################

  # none

  ############################ object tests #################################

  test 'valid AQO saves' do
    assert @option.save!
  end

  ########################### property tests ################################

  # assessment_question
  test 'assessment_question is required' do
    @option.assessment_question = nil
    assert !@option.save
  end

  # index
  test 'index is required' do
    @option.index = nil
    assert !@option.save
  end

  # name
  test 'name is required' do
    @option.name = nil
    assert !@option.save
  end

  ############################ method tests #################################

  # none

  ########################## association tests ##############################

  # assessment_question_responses
  test 'assessment question responses are destroyed on delete' do
    aqr = assessment_question_responses(:one)
    @option.assessment_question_responses << aqr
    @option.destroy!
    assert aqr.destroyed?
  end

end
