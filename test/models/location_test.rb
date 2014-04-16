require 'test_helper'

class LocationTest < ActiveSupport::TestCase

  def setup
    @location = locations(:location_one)
  end

  ############################ object tests #################################

  test 'valid location saves' do
    assert @location.save
  end

  ########################### property tests ################################

  # name
  test 'name is required' do
    @location.name = nil
    assert !@location.save
  end

  ########################### dependency tests ###############################

  test 'resources should be destroyed on destroy' do
    resource = resources(:resource_two)
    @location.resources << resource
    @location.destroy
    assert resource.destroyed?
  end

end
