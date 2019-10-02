require 'test_helper'
require 'rexml/document'

class ResourceTest < ActiveSupport::TestCase

  # TODO: add tests for Assessable methods

  def setup
    @resource = resources(:magna_carta)
  end

  ######################### class method tests ##############################

  test 'from_ead should raise an exception if given invalid XML' do
    assert_raises Nokogiri::XML::SyntaxError do
      Resource.from_ead('<cats></oops', users(:normal).id)
    end
  end

  test 'from_ead should return correct resource attributes' do
    xml = File.read('test/models/archivesspace_ead_export.xml')
    resource = Resource.from_ead(xml, users(:normal))

    assert_equal 'Here is a brief', resource.description[0..14]
    assert_nil resource.format
    assert_equal '15.31.26', resource.local_identifier
    assert_nil resource.location_id
    assert_equal 'Mandeville Collection', resource.name
    assert_equal 0, resource.resource_notes.length
    assert_equal 0, resource.resource_type
    assert_equal users(:normal).username, resource.user.username
    assert_equal 'Davis, Michael J., 1942-', resource.creators.first.name
    assert_equal '229 Photographic Prints', resource.extents.first.name
    assert_equal '5 boxes, 2 oversized boxes, 8 oversized folders',
                 resource.extents[1].name
    assert_equal 1, resource.resource_dates.first.date_type
    assert_equal 1965, resource.resource_dates.first.begin_year
    assert_equal 1985, resource.resource_dates.first.end_year
    assert_equal 'Alaska--Description and travel.', resource.subjects.first.name
  end

  ############################ object tests #################################

  test 'valid resource saves' do
    assert @resource.save
  end

  test 'assessment score and percent complete should update before save' do
    skip # TODO: write this
  end

  test 'setting a resource to a collection should prune its AQRs' do
    response = assessment_question_responses(:one)
    @resource.assessment_question_responses << response
    @resource.resource_type = Resource::Type::COLLECTION
    @resource.save
    assert !@resource.assessment_question_responses.any?
  end

  test 'resource should have a unique name scoped to its parent' do
    # same name and parent should fail
    resource2 = @resource.dup
    resource2.name = @resource.name
    assert !resource2.save
    # same name, different parent should succeed
    resource2.parent = resources(:uiuc_collection)
    assert resource2.save
  end

  test 'location should be synched with parent location' do
    @resource.parent = resources(:uiuc_collection)
    @resource.location = locations(:back_room)
    @resource.save!
    assert_equal locations(:secret), @resource.location
  end

  ########################### property tests ################################

  test 'assessment_complete should update properly' do
    @resource.save
    assert @resource.assessment_complete

    @resource.assessment_question_responses.destroy_all
    @resource.save
    assert !@resource.assessment_complete
  end

  # assessment_score
  test 'assessment_score should be within bounds' do
    @resource.assessment_score = -0.5
    assert !@resource.save

    @resource.assessment_score = 1.1
    assert !@resource.save

    @resource.assessment_score = 0.8
    assert @resource.save
  end

  # assessment_type
  test 'assessment_type is not required' do
    @resource.assessment_type = nil
    assert @resource.save
  end

  test 'assessment_type should be within bounds' do
    @resource.assessment_type = Assessment::Type.all.last + 1
    assert !@resource.save
  end

  # filename
  test 'filename should return local identifier if available' do
    assert_equal 'qwertyuiop', @resource.local_identifier
  end

  test 'filename should return object id if local identifier is not available' do
    @resource.local_identifier = nil
    assert_match /resource-\d+/, @resource.filename
  end

  test 'filename should return class name if object id is not available' do
    @resource.local_identifier = nil
    @resource.id = nil
    assert_equal 'resource', @resource.filename
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
    @resource.resource_type = Resource::Type::COLLECTION
    assert_equal 'Collection', @resource.readable_resource_type
    @resource.resource_type = Resource::Type::ITEM
    assert_equal 'Item', @resource.readable_resource_type
  end

  # readable_resource_significance
  test 'readable_significance should work' do
    @resource.significance = Resource::Significance::LOW
    assert_equal 'Low', @resource.readable_significance
    @resource.significance = Resource::Significance::MODERATE
    assert_equal 'Moderate', @resource.readable_significance
    @resource.significance = Resource::Significance::HIGH
    assert_equal 'High', @resource.readable_significance
  end

  # resource_type
  test 'resource_type is required' do
    @resource.resource_type = nil
    assert !@resource.save
  end

  test 'resource_type is in bounds' do
    @resource.resource_type = Resource::Type.all.last + 1
    assert !@resource.save
  end

  # significance
  test 'significance can be blank' do
    @resource.significance = nil
    assert @resource.save
  end

  test 'significance is in bounds' do
    @resource.significance = Resource::Significance.all.last + 1
    assert !@resource.save
  end

  # user
  test 'user is required' do
    @resource.user = nil
    assert !@resource.save
  end

  ############################# method tests #################################

  # all_assessed_items
  test 'all_assessed_items doesn\'t error out' do
    resources(:uiuc_collection).all_assessed_items
  end

  test 'all_assessed_items should work' do
    skip # TODO: write this
  end

  # all_children
  test 'all_children should work' do
    assert_equal 0, resources(:uiuc_collection).all_children.length
    assert_equal 5, resources(:cat_fancy_collection).all_children.length
  end

  # all_parents
  test 'all_parents returns an empty array for resources with no parents' do
    assert_equal 0, @resource.all_parents.length
  end

  test 'all_parents returns all parents of resources with parents' do
    assert_equal 2, resources(:cat_fancy_special_issue).all_parents.length
  end

  # as_csv
  test 'as_csv works' do
    csv = @resource.as_csv
    assert csv.end_with?("\n")
  end

  # assessed_item_statistics
  test 'assessed_item_statistics should work' do
    skip # TODO: write this
  end

  # dup
  test 'dup should produce a correct clone' do
    clone = @resource.dup
    assert_equal @resource.assessment_question_responses.length,
                 clone.assessment_question_responses.length
    assert_equal @resource.creators.length, clone.creators.length
    assert_equal @resource.extents.length, clone.extents.length
    assert_equal @resource.resource_dates.length, clone.resource_dates.length
    assert_equal @resource.resource_notes.length, clone.resource_notes.length
    assert_equal @resource.subjects.length, clone.subjects.length
    assert_equal 'Clone of ' + @resource.name, clone.name
  end

  test 'dup truncates long names' do
    @resource.name = 'a' * Resource::MAX_NAME_LENGTH
    clone = @resource.dup

    assert_equal "Clone of #{'a' * (Resource::MAX_NAME_LENGTH - 9)}", clone.name
    assert clone.name.length <= Resource::MAX_NAME_LENGTH

    clone2 = clone.dup
    assert_equal "Clone of Clone of #{'a' * (Resource::MAX_NAME_LENGTH - 18)}",
                 clone2.name
    assert clone2.name.length <= Resource::MAX_NAME_LENGTH
  end

  # effective_format_score
  test 'effective_format_score should set 0 if no format' do
    @resource.format = nil
    assert_equal 0, @resource.effective_format_score
  end

  test 'effective_format_score should work for bound paper and original documents' do
    skip # TODO: write this
  end

  test 'effective_format_score should work for non-bound paper and non-original documents' do
    skip # TODO: write this
  end

  # format_tree
  test 'format_tree works' do
    @resource.format = formats(:wetter_bath_towel)
    @resource.save!
    assert_equal [formats(:wet_bath_towel), formats(:wetter_bath_towel)],
                 @resource.format_tree
  end

  # prune_empty_submodels
  test 'prune_empty_submodels works' do
    resource = resources(:cat_fancy_issue_3)
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

  # update_assessment_complete
  test 'update_assessment_complete should set false if no format' do
    @resource.format = nil
    @resource.update_assessment_complete
    assert !@resource.assessment_complete
  end

  test 'update_assessment_complete should set false if format has no assessment questions' do
    @resource.format = formats(:wet_bath_towel)
    @resource.update_assessment_complete
    assert !@resource.assessment_complete
  end

  test 'update_assessment_complete should work when a format with assessment questions is set and a response exists' do
    @resource.update_assessment_complete
    assert @resource.assessment_complete
  end

  # update_assessment_score
  test 'update_assessment_score should calculate properly' do
    @resource.update_assessment_score
    assert_equal 0.005, @resource.assessment_score.to_f
  end

  ########################### association tests ##############################

  test 'assessment question responses should be destroyed on destroy' do
    response = assessment_question_responses(:one)
    @resource.assessment_question_responses << response
    @resource.destroy
    assert response.destroyed?
  end

  test 'children should be destroyed on destroy' do
    child = resources(:dead_sea_scrolls)
    @resource.children << child
    @resource.destroy
    assert child.destroyed?
  end

  test 'dependent creators should be destroyed on destroy' do
    creator = creators(:one)
    @resource.creators << creator
    @resource.destroy
    assert creator.destroyed?
  end

  test 'dependent extents should be destroyed on destroy' do
    extent = extents(:one)
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
    note = resource_notes(:one)
    @resource.resource_notes << note
    @resource.destroy
    assert note.destroyed?
  end

  test 'dependent subjects should be destroyed on destroy' do
    subject = subjects(:one)
    @resource.subjects << subject
    @resource.destroy
    assert subject.destroyed?
  end

  test 'resource cannot be a child of an item' do
    resource2 = resources(:dead_sea_scrolls)
    resource2.parent = @resource
    assert !resource2.save
  end

  test 'resource\'s owning user must be of the same institution unless an admin' do
    @resource.user = users(:disabled)
    assert !@resource.save

    @resource.user = users(:non_uiuc_admin)
    assert @resource.save
  end

end
