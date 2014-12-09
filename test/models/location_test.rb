require 'test_helper'

class LocationTest < ActiveSupport::TestCase

  def setup
    @location = locations(:location_one)
  end

  ######################### class method tests ##############################

  # none

  ############################ object tests #################################

  test 'valid location saves' do
    assert @location.save
  end

  test 'assessment score is updated on save' do
    flunk # TODO: write this
  end

  ########################### property tests ################################

  # assessment_score
  test 'assessment_score can be blank' do
    @location.assessment_score = nil
    assert @location.save
  end

  test 'assessment_score should be between 0 and 1' do
    @location.assessment_score = -0.5
    assert !@location.save

    @location.assessment_score = 1.5
    assert !@location.save
  end

  # name
  test 'name is required' do
    @location.name = nil
    assert !@location.save
  end

  test 'repository is required' do
    @location.repository = nil
    assert !@location.save
  end

  ############################# method tests #################################

  # none

  ########################### association tests ##############################

  test 'dependent assessment question responses should be destroyed on destroy' do
    response = assessment_question_responses(:assessment_question_response_one)
    @location.assessment_question_responses << response
    @location.destroy
    assert response.destroyed?
  end

  test 'dependent resources should be destroyed on destroy' do
    resource = resources(:resource_two)
    @location.resources << resource
    @location.destroy
    assert resource.destroyed?
  end

  test 'dependent temperature ranges should be destroyed on destroy' do
    range = temperature_ranges(:temp_range_one)
    @location.temperature_range = range
    @location.destroy
    assert range.destroyed?
  end

end
