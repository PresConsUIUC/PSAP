require 'test_helper'

class AssessmentTest < ActiveSupport::TestCase

  def setup
    @assessment = assessments(:resource_assessment)
  end

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

  # name
  test 'name is required' do
    @assessment.name = nil
    assert !@assessment.save
  end

end
