require 'test_helper'

class RepositoryTest < ActiveSupport::TestCase

  def setup
    @repository = repositories(:repository_one)
  end

  ######################### class method tests ##############################

  # none

  ############################ object tests #################################

  test 'valid repository saves' do
    assert @repository.save
  end

  ########################### property tests ################################

  # name
  test 'name is required' do
    @repository.name = nil
    assert !@repository.save
  end

  test 'name should be no more than 255 characters long' do
    @repository.name = 'a' * 256
    assert !@repository.save
  end

  # institution
  test 'institution is required' do
    @repository.institution = nil
    assert !@repository.save
  end

  ########################### association tests ##############################

  test 'locations should be destroyed on destroy' do
    location = locations(:location_two)
    @repository.locations << location
    @repository.destroy
    assert location.destroyed?
  end

  ############################# method tests #################################

  # none

  ########################### association tests ##############################

  test 'dependent locations should be destroyed on destroy' do
    location = locations(:location_one)
    @repository.locations << location
    @repository.destroy
    assert location.destroyed?
  end

end
