require 'test_helper'

class AssessmentSectionTest < ActiveSupport::TestCase

  def setup
    @section = assessment_sections(:assessment_section_one)
  end

  ############################ object tests #################################

  test 'valid assessment section saves' do
    assert @section.save
  end

  ########################### property tests ################################

  # assessment
  test 'assessment is required' do
    @section.assessment = nil
    assert !@section.save
  end

  # index
  test 'index is required' do
    @section.index = nil
    assert !@section.save
  end

  # name
  test 'name is required' do
    @section.name = nil
    assert !@section.save
  end

  ########################### dependency tests ###############################

  test 'dependent assessment questions should be destroyed on destroy' do
    question = assessment_questions(:assessment_question_one)
    @section.assessment_questions << question
    @section.destroy
    assert question.destroyed?
  end

end
