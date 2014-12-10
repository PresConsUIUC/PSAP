require 'test_helper'

class ResourceNoteTest < ActiveSupport::TestCase

  def setup
    @default_values = {value: 'Test'}
    @note = ResourceNote.new(@default_values)
    @note.resource = resources(:resource_one)
  end

  ######################### class method tests ##############################

  # none

  ############################ object tests #################################

  test 'valid resource note saves' do
    assert @note.save
  end

  ########################### property tests ################################

  # value
  test 'value is required' do
    @note.value = nil
    assert !@note.save
  end

  # resource
  test 'resource is required' do
    @note.resource = nil
    assert !@note.save
  end

  ############################# method tests #################################

  # none

  ########################### association tests ##############################

  # none

end
