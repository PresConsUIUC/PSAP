require 'test_helper'

class FormatTest < ActiveSupport::TestCase

  def setup
    @format = formats(:format_one)
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
    @format.temperature_ranges << temperature_ranges(:temp_range_one)
    @format.temperature_ranges << temperature_ranges(:temp_range_two)
    @format.temperature_ranges << temperature_ranges(:temp_range_three)
    assert @format.save

    temperature_ranges(:temp_range_one).max_temp_f = 53
    assert !@format.save
  end

  ############################ method tests #################################

  test 'all_assessment_questions should work' do
    assert_equal assessment_questions(:assessment_question_one),
                 @format.all_assessment_questions[0]
  end

  ########################## association tests ##############################

  test 'children should be destroyed on destroy' do
    @format.resources.destroy_all
    child = formats(:format_three)
    @format.children << child
    @format.destroy
    assert child.destroyed?
  end

  test 'cannot be deleted if there are dependent resources' do
    assert_raises ActiveRecord::DeleteRestrictionError do
      assert !@format.destroy
    end
  end

  test 'dependent temperature ranges should be destroyed on destroy' do
    @format.resources.destroy_all
    range = temperature_ranges(:temp_range_one)
    @format.temperature_ranges << range
    @format.destroy
    assert range.destroyed?
  end

end
