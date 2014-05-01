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

  test 'events are read-only once created' do
    @event.save
    @event.description = 'test2'
    assert_raises ActiveRecord::ReadOnlyRecord do
      assert !@event.save
      assert !@event.destroy
    end
  end

  ########################### property tests ################################

  # description
  test 'description is required' do
    @event.description = nil
    assert !@event.save
  end

  # event_status
  test 'event_status should be valid' do
    @event.event_status = EventStatus.all.last + 1
    assert !@event.save
  end

end
