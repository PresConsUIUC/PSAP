require 'test_helper'

class AssessmentQuestionOptionTest < ActiveSupport::TestCase

  def setup
    @option = assessment_question_options(:assessment_question_option_one)
  end

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

  # value
  test 'value is required' do
    @option.value = nil
    assert !@option.save
  end

end
