require 'test_helper'

class LocationTest < ActiveSupport::TestCase

  def setup
    @location = locations(:secret)
  end

  ######################### class method tests ##############################

  # none

  ############################ object tests #################################

  test 'valid location saves' do
    assert @location.save
  end

  test 'assessment score should update on save' do
    skip # TODO: write this
  end

  test 'location should have a unique name scoped to its repository' do
    # same name and repository should fail
    location2 = @location.dup
    assert !location2.save
    # same name, different institution should succeed
    location2.repository = repositories(:four)
    assert location2.save
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
    response = assessment_question_responses(:one)
    @location.assessment_question_responses << response
    @location.destroy
    assert response.destroyed?
  end

  test 'dependent resources should be destroyed on destroy' do
    resource = resources(:dead_sea_scrolls)
    @location.resources << resource
    @location.destroy
    assert resource.destroyed?
  end

end
