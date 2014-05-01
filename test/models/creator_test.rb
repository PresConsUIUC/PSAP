require 'test_helper'

class CreatorTest < ActiveSupport::TestCase

  def setup
    @default_values = {name: 'Test', creator_type: CreatorType::PERSON}
    @creator = Creator.new(@default_values)
    @creator.resource = resources(:resource_one)
  end

  ############################ object tests #################################

  test 'valid creator saves' do
    assert @creator.save
  end

  ########################### property tests ################################

  # name
  test 'name is required' do
    @creator.name = nil
    assert !@creator.save
  end

  # creator type
  test 'creator type is required' do
    @creator.creator_type = nil
    assert !@creator.save
  end

  test 'creator type is valid' do
    @creator.creator_type = CreatorType.all.last + 10
    assert !@creator.save
  end

end
