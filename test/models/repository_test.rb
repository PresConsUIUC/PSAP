require 'test_helper'

class RepositoryTest < ActiveSupport::TestCase

  def setup
    @repository = repositories(:repository_one)
  end

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

end
