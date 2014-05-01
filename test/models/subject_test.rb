require 'test_helper'

class SubjectTest < ActiveSupport::TestCase

  def setup
    @default_values = {name: 'Test'}
    @subject = Subject.new(@default_values)
    @subject.resource = resources(:resource_one)
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

  # resource
  test 'resource is required' do
    @subject.resource = nil
    assert !@subject.save
  end

end
