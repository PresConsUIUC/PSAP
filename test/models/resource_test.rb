require 'test_helper'

class ResourceTest < ActiveSupport::TestCase

  # TODO: add tests for Assessable methods

  def setup
    @resource = resources(:resource_one)
  end

  ######################### class method tests ##############################

  test 'from_ead should work properly' do
    flunk # TODO: write this
  end

  ############################ object tests #################################

  test 'valid resource saves' do
    assert @resource.save
  end

  test 'assessment score and percent complete should update before save' do
    flunk # TODO: write this
  end

  ########################### property tests ################################

  # assessment_percent_complete
  test 'assessment_percent_complete should be within bounds' do
    @resource.assessment_percent_complete = -0.5
    assert !@resource.save

    @resource.assessment_percent_complete = 1.1
    assert !@resource.save

    @resource.assessment_percent_complete = 0.8
    assert @resource.save
  end

  test 'assessment_percent_complete should update properly' do
    @resource.save
    assert_equal 1, @resource.assessment_percent_complete

    @resource.assessment_question_responses.destroy_all
    @resource.save
    assert_equal 0, @resource.assessment_percent_complete
  end

  test 'assessment_score should be within bounds' do
    @resource.assessment_score = -0.5
    assert !@resource.save

    @resource.assessment_score = 1.1
    assert !@resource.save

    @resource.assessment_score = 0.8
    assert @resource.save
  end

  # filename
  test 'filename should return local identifier if available' do
    assert_equal 'qwertyuiop', @resource.local_identifier
  end

  test 'filename should return object id if local identifier is not available' do
    @resource.local_identifier = nil
    assert_equal '1', @resource.filename
  end

  # location
  test 'location is required' do
    @resource.location = nil
    assert !@resource.save
  end

  # name
  test 'name is required' do
    @resource.name = nil
    assert !@resource.save
  end

  # readable_resource_type
  test 'readable_resource_type should work' do
    @resource.resource_type = ResourceType::COLLECTION
    assert_equal 'Collection', @resource.readable_resource_type
    @resource.resource_type = ResourceType::ITEM
    assert_equal 'Item', @resource.readable_resource_type
  end

  # readable_resource_significance
  test 'readable_significance should work' do
    @resource.significance = ResourceSignificance::LOW
    assert_equal 'Low', @resource.readable_significance
    @resource.significance = ResourceSignificance::MODERATE
    assert_equal 'Moderate', @resource.readable_significance
    @resource.significance = ResourceSignificance::HIGH
    assert_equal 'High', @resource.readable_significance
  end

  # resource_type
  test 'resource_type is required' do
    @resource.resource_type = nil
    assert !@resource.save
  end

  test 'resource_type is in bounds' do
    @resource.resource_type = ResourceType.all.last + 1
    assert !@resource.save
  end

  # significance
  test 'significance can be blank' do
    @resource.significance = nil
    assert @resource.save
  end

  test 'significance is in bounds' do
    @resource.significance = ResourceSignificance.all.last + 1
    assert !@resource.save
  end

  # user
  test 'user is required' do
    @resource.user = nil
    assert !@resource.save
  end

  ############################# method tests #################################

  # all_assessed_items
  test 'all_assessed_items should work' do
    flunk # TODO: write this
  end

  # all_children
  test 'all_children should work' do
    flunk # TODO: write this
  end

  # as_csv
  test 'as_csv should work' do
    flunk # TODO: write this
  end

  # assessed_item_statistics
  test 'assessed_item_statistics should work' do
    flunk # TODO: write this
  end

  # assessment_percent_complete_in_section
  test 'assessment_percent_complete_in_section should work' do
    flunk # TODO: write this
  end

  # from_ead
  test 'from_ead should work' do
    flunk # TODO: write this
  end

  # prune_empty_submodels
  test 'prune_empty_submodels should work' do
    resource = resources(:resource_twelve)
    resource.creators << Creator.new(name: 'bla')
    resource.creators << Creator.new(name: '')
    resource.prune_empty_submodels
    assert_equal 1, resource.creators.length

    resource.extents << Extent.new(name: 'bla')
    resource.extents << Extent.new(name: '')
    resource.prune_empty_submodels
    assert_equal 1, resource.extents.length

    resource.resource_dates << ResourceDate.new(year: 1990)
    resource.resource_dates << ResourceDate.new(year: nil)
    resource.prune_empty_submodels
    assert_equal 1, resource.resource_dates.length

    resource.resource_notes << ResourceNote.new(value: 'bla')
    resource.resource_notes << ResourceNote.new(value: '')
    resource.prune_empty_submodels
    assert_equal 1, resource.resource_notes.length

    resource.subjects << Subject.new(name: 'bla')
    resource.subjects << Subject.new(name: '')
    resource.prune_empty_submodels
    assert_equal 1, resource.subjects.length
  end

  # total_assessment_score
  test 'total_assessment_score should work' do
    flunk # TODO: write this
  end

  # update_assessment_percent_complete
  test 'update_assessment_percent_complete should set 0 if no format' do
    @resource.format = nil
    @resource.update_assessment_percent_complete
    assert_equal 0, @resource.assessment_percent_complete
  end

  test 'update_assessment_percent_complete should set 0 if format has no assessment questions' do
    @resource.format = formats(:format_four)
    @resource.update_assessment_percent_complete
    assert_equal 0, @resource.assessment_percent_complete
  end

  test 'update_assessment_percent_complete should work when a format with assessment questions is set and a response exists' do
    @resource.update_assessment_percent_complete
    assert_equal 1, @resource.assessment_percent_complete
  end

  # update_assessment_score
  test 'update_assessment_score should set 0 if no format' do
    @resource.format = nil
    @resource.update_assessment_score
    assert_equal 0, @resource.assessment_score
  end

  test 'update_assessment_score should work for bound paper and original documents' do
    flunk # TODO: write this
  end

  test 'update_assessment_score should work for non-bound paper and non-original documents' do
    flunk # TODO: write this
  end

  ########################### association tests ##############################

  test 'assessment question responses should be destroyed on destroy' do
    response = assessment_question_responses(:assessment_question_response_one)
    @resource.assessment_question_responses << response
    @resource.destroy
    assert response.destroyed?
  end

  test 'children should be destroyed on destroy' do
    child = resources(:resource_two)
    @resource.children << child
    @resource.destroy
    assert child.destroyed?
  end

  test 'dependent creators should be destroyed on destroy' do
    creator = creators(:creator_one)
    @resource.creators << creator
    @resource.destroy
    assert creator.destroyed?
  end

  test 'dependent extents should be destroyed on destroy' do
    extent = extents(:extent_one)
    @resource.extents << extent
    @resource.destroy
    assert extent.destroyed?
  end

  test 'dependent resource dates should be destroyed on destroy' do
    date = resource_dates(:bulk_date)
    @resource.resource_dates << date
    @resource.destroy
    assert date.destroyed?
  end

  test 'dependent resource notes should be destroyed on destroy' do
    note = resource_notes(:resource_note_one)
    @resource.resource_notes << note
    @resource.destroy
    assert note.destroyed?
  end

  test 'dependent subjects should be destroyed on destroy' do
    subject = subjects(:subject_one)
    @resource.subjects << subject
    @resource.destroy
    assert subject.destroyed?
  end

  test 'resource cannot be a child of an item' do
    resource2 = resources(:resource_two)
    resource2.parent = @resource
    assert !resource2.save
  end

  test 'resource cannot have more than one response to the same assessment question' do
    @resource.assessment_question_responses <<
        assessment_question_responses(:assessment_question_response_one)
    @resource.assessment_question_responses <<
        assessment_question_responses(:assessment_question_response_one_point_five)
    assert !@resource.save
  end

end
