require 'test_helper'

class AssessmentTest < ActiveSupport::TestCase

  def setup
    @assessment = assessments(:resource_assessment)
  end

  ######################### class method tests ##############################

  # none

  ############################ object tests #################################

  test 'valid assessments can be created' do
    assert Assessment.create(name: 'test', key: 'test')
  end

  test 'assessments are read-only once created' do
    assessment = Assessment.create(name: 'test', key: 'test')
    assessment.name = 'test2'
    assert_raises ActiveRecord::ReadOnlyRecord do
      assert !assessment.save
      assert !assessment.destroy
    end
  end

  ########################### property tests ################################

  # key
  test 'key is required' do
    @assessment.key = nil
    assert !@assessment.save
  end

  test 'key should be 30 characters or less' do
    @assessment.key = 'a' * 31
    assert !@assessment.save
  end

  # name
  test 'name is required' do
    @assessment.name = nil
    assert !@assessment.save
  end

  test 'name should be 255 characters or less' do
    @assessment.name = 'a' * 256
    assert !@assessment.save
  end

  ############################ method tests #################################

  test 'to_param should return key' do
    assert_equal 'resource', @assessment.to_param
  end

  ########################## association tests ##############################

  test 'dependent assessment sections should be destroyed on destroy' do
    section = assessment_sections(:assessment_section_one)
    # have to use a new one because existing ones are read-only
    @assessment = Assessment.new
    @assessment.assessment_sections << section
    @assessment.destroy
    assert section.destroyed?
  end

end
