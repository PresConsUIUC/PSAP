require 'test_helper'

class HumidityRangeTest < ActiveSupport::TestCase

  def setup
    @range = humidity_ranges(:two)
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

  # min_rh & max_rh
  test 'min_rh should be less than max_rh' do
    @range.min_rh = 50
    @range.max_rh = 40
    assert !@range.save
  end

  # max_rh
  test 'max_rh is required' do
    @range.max_rh = nil
    assert !@range.save
  end

  # min_rh
  test 'min_rh is required' do
    @range.min_rh = nil
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
