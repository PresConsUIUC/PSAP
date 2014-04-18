require 'test_helper'

class FormatTest < ActiveSupport::TestCase

  setup :setup

  protected

  def setup
    @default_values = {name: 'Test', score:0.5}
    @format = Format.new(@default_values)
  end

  ############################ object tests #################################

  test 'valid format saves' do
    assert @format.save
  end

  test 'formats are initialized with a default temperature range' do
    assert_equal 1, @format.temperature_ranges.length
  end

  ########################### property tests ################################

  # name
  test 'name is required' do
    @format.name = nil
    assert !@format.save
  end

  test 'name is case-insensitively unique' do
    assert @format.save

    format2 = Format.new(@default_values)
    format2.name = format2.name.upcase
    assert !format2.save
  end

  # score
  test 'score is required' do
    @format.score = nil
    assert !@format.save
  end

  test 'score is >= 0' do
    @format.score = -0.2
    assert !@format.save
  end

  test 'score is <= 1' do
    @format.score = 1.1
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

end
