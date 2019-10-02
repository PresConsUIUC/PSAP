require 'test_helper'

class AssessmentSectionTest < ActiveSupport::TestCase

  def setup
    @section = assessment_sections(:one)
  end

  ######################### class method tests ##############################

  # none

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

  test 'name should be 255 characters or less' do
    @section.name = 'a' * 256
    assert !@section.save
  end

  test 'name must be unique within the same assessment' do
    @section.name = 'cats'
    @section.save
    section2 = assessment_sections(:two)
    section2.name = 'cats'
    assert !section2.save
  end

  test 'name does not have to be unique across assessments' do
    @section.name = 'cats'
    @section.save
    section2 = assessment_sections(:three)
    section2.name = 'cats'
    assert section2.save
  end

  ############################ method tests #################################

  test 'assessment_questions_for_format returns an empty set if no format supplied' do
    assert_equal 0, @section.assessment_questions_for_format(nil).length
  end

  test 'assessment_questions_for_format works when a format is supplied' do
    skip # TODO: write this
  end

  test 'max_score should work properly' do
    assert_equal 1, @section.max_score
  end

  test 'max_score should work properly with a resource supplied' do
    assert_equal 1, @section.max_score(resources(:magna_carta))
  end

  ########################### association tests ##############################

  test 'dependent assessment questions should be destroyed on destroy' do
    question = assessment_questions(:one)
    @section.assessment_questions << question
    @section.destroy
    assert question.destroyed?
  end

end
