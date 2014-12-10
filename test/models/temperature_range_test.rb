require 'test_helper'

class TemperatureRangeTest < ActiveSupport::TestCase

  def setup
    @range = temperature_ranges(:temp_range_two)
  end

  ######################### class method tests ##############################

  # none

  ############################ object tests #################################

  test 'valid range saves' do
    assert @range.save
  end

  ########################### property tests ################################

  # format
  test 'format is required' do
    @range.format = nil
  end

  # min_temp_f & max_temp_f
  test 'min_temp_f should be less than max_temp_f' do
    @range.min_temp_f = 50
    @range.max_temp_f = 40
    assert !@range.save
  end

  test 'either min_temp_f or max_temp_f is required' do
    @range.min_temp_f = nil
    @range.max_temp_f = nil
    assert !@range.save
  end

  # score
  test 'score is required' do
    @range.score = nil
    assert !@range.save
  end

  test 'score should be between 0 and 1' do
    @range.score = 1.1
    assert !@range.save
    @range.score = -0.4
    assert !@range.save
  end

  ############################# method tests #################################

  # none

  ########################### association tests ##############################

  # none

end
