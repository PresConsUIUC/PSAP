require 'test_helper'

class ResourceTest < ActiveSupport::TestCase

  def setup
    @resource = resources(:resource_one)
  end

  ############################ object tests #################################

  test 'valid resource saves' do
    assert @resource.save
  end

  ########################### property tests ################################

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

  # resource_type
  test 'resource_type is required' do
    @resource.resource_type = nil
    assert !@resource.save
  end

  # user
  test 'user is required' do
    @resource.user = nil
    assert !@resource.save
  end

  ########################### dependency tests ###############################

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

end
