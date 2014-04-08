require 'test_helper'

class ExtentTest < ActiveSupport::TestCase

  setup :setup

  protected

  def setup
    @default_values = {name: 'Test'}
    @extent = Extent.new(@default_values)
    @extent.resource = resources(:resource_one)
  end

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

end
