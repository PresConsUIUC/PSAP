require 'test_helper'

class SubjectTest < ActiveSupport::TestCase

  setup :setup

  protected

  def setup
    @default_values = {name: 'Test'}
    @subject = Subject.new(@default_values)
  end

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

end
