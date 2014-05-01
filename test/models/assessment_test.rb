require 'test_helper'

class AssessmentTest < ActiveSupport::TestCase

  def setup
    @assessment = assessments(:resource_assessment)
  end

  ############################ object tests #################################

  test 'valid assessment saves' do
    assert @assessment.save
  end

  ########################### property tests ################################

  # key
  test 'key is required' do
    @assessment.key = nil
    assert !@assessment.save
  end

  # name
  test 'name is required' do
    @assessment.name = nil
    assert !@assessment.save
  end

  ########################### dependency tests ###############################

  test 'dependent assessment sections should be destroyed on destroy' do
    section = assessment_sections(:resource_assessment_section_one)
    @assessment.assessment_sections << section
    @assessment.destroy
    assert section.destroyed?
  end

end
