require 'test_helper'

class EventTest < ActiveSupport::TestCase

  def setup
    @default_values = {description: 'Test'}
    @event = Event.new(@default_values)
  end

  ############################ object tests #################################

  test 'valid event saves' do
    assert @event.save
  end

  ########################### property tests ################################

  # description
  test 'description is required' do
    @event.description = nil
    assert !@event.save
  end

end
