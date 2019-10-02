require 'test_helper'

class SubjectTest < ActiveSupport::TestCase

  def setup
    @subject = subjects(:one)
  end

  ######################### class method tests ##############################

  # none

  ############################ object tests #################################

  test 'valid subject saves' do
    assert @subject.save
  end

  ########################### property tests ################################

  # name
  test 'name is required' do
    @subject.name = nil
    assert !@subject.save
  end

  test 'name should be no more than 255 characters' do
    @subject.name = 'a' * 256
    assert !@subject.save
  end

  # resource
  test 'resource is required' do
    @subject.resource = nil
    assert !@subject.save
  end

  ############################# method tests #################################

  # none

  ########################### association tests ##############################

  # none

end
