require 'test_helper'

class LanguageTest < ActiveSupport::TestCase

  def setup
    @language = languages(:english)
    @default_values = languages(:english).attributes
  end

  ######################### class method tests ##############################

  # none

  ############################ object tests #################################

  test 'valid language saves' do
    assert @language.save
  end

  ########################### property tests ################################

  # english_name
  test 'english_name is required' do
    @language.english_name = nil
    assert !@language.save
  end

  test 'english_name should be no longer than 255 characters' do
    @language.english_name = 'a' * 256
    assert !@language.save
  end

  test 'english_name should be case-insensitively unique' do
    assert @language.save

    lang2 = Language.new(@default_values)
    lang2.english_name = lang2.english_name.upcase
    assert !lang2.save
  end

  # iso639_2_code
  test 'iso639_2_code is required' do
    @language.iso639_2_code = nil
    assert !@language.save
  end

  test 'iso639_2_code should be 3 characters' do
    @language.iso639_2_code = 'abcd'
    assert !@language.save

    @language.iso639_2_code = 'ab'
    assert !@language.save
  end

  # native_name
  test 'native_name is required' do
    @language.native_name = nil
    assert !@language.save
  end

  test 'native_name should be no longer than 255 characters' do
    @language.native_name = 'a' * 256
    assert !@language.save
  end

  ############################# method tests #################################

  # none

  ########################### association tests ##############################

  # none

end
