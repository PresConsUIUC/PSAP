require 'test_helper'

class FormatTest < ActiveSupport::TestCase

  def setup
    @format = formats(:used_napkin)
  end

  ######################### class method tests ##############################

  # none

  ############################ object tests #################################

  test 'valid format saves' do
    assert @format.save
  end

  ########################### property tests ################################

  # format_class
  test 'format_class is required' do
    @format.format_class = nil
    assert !@format.save
  end

  test 'format_class should be an allowed value' do
    @format.format_class = FormatClass.all.last + 1
    assert !@format.save
  end

  # name
  test 'name is required' do
    @format.name = nil
    assert !@format.save
  end

  test 'name should be 255 characters or less' do
    @format.name = 'a' * 256
    assert !@format.save
  end

  # temperature_ranges
  test 'temperature ranges should be sequential' do
    @format.temperature_ranges << temperature_ranges(:one)
    @format.temperature_ranges << temperature_ranges(:two)
    @format.temperature_ranges << temperature_ranges(:three)
    assert @format.save

    temperature_ranges(:one).max_temp_f = 53
    assert !@format.save
  end

  ############################ method tests #################################

  test 'all_assessment_questions should work' do
    assert_equal assessment_questions(:one),
                 @format.all_assessment_questions[0]
  end

  # requires_type_vectors?
  test 'requires_type_vectors? should return true for Original Document and Bound Paper' do
    @format.fid = 159
    assert @format.requires_type_vectors?
    @format.fid = 160
    assert @format.requires_type_vectors?
  end

  test 'requires_type_vectors? should return false for all other formats' do
    @format.fid = 120
    assert !@format.requires_type_vectors?
  end

  test 'temperature_range_in_location should work properly' do
    skip # TODO: write this
  end

  ########################## association tests ##############################

  test 'children should be destroyed on destroy' do
    @format.resources.destroy_all
    child = formats(:dirty_bed_sheet)
    @format.children << child
    @format.destroy
    assert child.destroyed?
  end

  test 'dependent humidity ranges should be destroyed on destroy' do
    @format.resources.destroy_all
    range = humidity_ranges(:one)
    @format.humidity_ranges << range
    @format.destroy
    assert range.destroyed?
  end

  test 'dependent temperature ranges should be destroyed on destroy' do
    @format.resources.destroy_all
    range = temperature_ranges(:one)
    @format.temperature_ranges << range
    @format.destroy
    assert range.destroyed?
  end

end
