require 'test_helper'

class AssessmentTest < ActiveSupport::TestCase

  # percent_complete
  test 'percent_complete is required' do
    @assessment.percent_complete = nil
    assert !@assessment.save
  end

  test 'percent_complete cannot be less than 0' do
    @assessment.percent_complete = -0.5
    assert !@assessment.save
  end

  test 'percent_complete cannot be greater than 1' do
    @assessment.percent_complete = 1.2
    assert !@assessment.save
  end

end
