require 'test_helper'

class EventTest < ActiveSupport::TestCase

  def setup
    @event = events(:info_event)
  end

  ######################### class method tests ##############################

  test 'matching_params should work' do
    flunk # TODO: write this
  end

  ############################ object tests #################################

  test 'valid event saves' do
    @event = Event.new(description: 'blabla', event_level: EventLevel::INFO)
    assert @event.save
  end

  test 'events are read-only once created' do
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

  ############################ method tests #################################

  test 'associated_entity_class should work' do
    @event.assessment_questions << assessment_questions(:assessment_question_one)
    assert_equal AssessmentQuestion, @event.associated_entity_class
    @event.assessment_questions.destroy_all

    @event.assessment_sections << assessment_sections(:assessment_section_one)
    assert_equal AssessmentSection, @event.associated_entity_class
    @event.assessment_sections.destroy_all

    @event.formats << formats(:format_one)
    assert_equal Format, @event.associated_entity_class
    @event.formats.destroy_all

    @event.institutions << institutions(:institution_one)
    assert_equal Institution, @event.associated_entity_class
    @event.institutions.destroy_all

    @event.locations << locations(:location_one)
    assert_equal Location, @event.associated_entity_class
    @event.locations.destroy_all

    @event.repositories << repositories(:repository_one)
    assert_equal Repository, @event.associated_entity_class
    @event.repositories.destroy_all

    @event.users << users(:normal_user)
    assert_equal User, @event.associated_entity_class
    @event.users.destroy_all

    assert_nil @event.associated_entity_class
  end

  ########################## association tests ##############################

  # none

end
