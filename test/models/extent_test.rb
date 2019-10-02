require 'test_helper'

class ExtentTest < ActiveSupport::TestCase

  def setup
    @extent = extents(:one)
  end

  ######################### class method tests ##############################

  # none

  ############################ object tests #################################

  test 'valid extent saves' do
    assert @extent.save
  end

  ########################### property tests ################################

  # name
  test 'name is required' do
    @extent.name = nil
    assert !@extent.save
  end

  test 'name should be 255 characters or less' do
    @extent.name = 'a' * 256
    assert !@extent.save
  end

  # resource
  test 'resource is required' do
    @extent.resource = nil
    assert !@extent.save
  end

  ############################ method tests #################################

  # none

  ########################## association tests ##############################

  # none

end
