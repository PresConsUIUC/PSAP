require 'test_helper'

class CreatorTest < ActiveSupport::TestCase

  def setup
    @creator = creators(:creator_one)
  end

  ######################### class method tests ##############################

  # none

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

  test 'name should be 255 characters or less' do
    @creator.name = 'a' * 256
    assert !@creator.save
  end

  # creator type
  test 'creator type is required' do
    @creator.creator_type = nil
    assert !@creator.save
  end

  test 'creator type should be valid' do
    @creator.creator_type = CreatorType.all.last + 10
    assert !@creator.save
  end

  # resource
  test 'resource is required' do
    @creator.resource = nil
    assert !@creator.save
  end

  ############################ method tests #################################

  test 'readable_creator_type should work' do
    @creator.creator_type = CreatorType::PERSON
    assert_equal 'Person', @creator.readable_creator_type
    @creator.creator_type = CreatorType::COMPANY
    assert_equal 'Company', @creator.readable_creator_type
  end

  ########################## association tests ##############################

  # none

end
