require 'test_helper'

class ResourceDateTest < ActiveSupport::TestCase

  def setup
    @resource_date = resource_dates(:bulk_date)
  end

  ######################### class method tests ##############################

  # none

  ############################ object tests #################################

  test 'valid resource date saves' do
    assert @resource_date.save
  end

  ########################### property tests ################################

  # date_type
  test 'date_type is required' do
    @resource_date.date_type = nil
    assert !@resource_date.save
  end

  test 'date_type should be valid' do
    @resource_date.date_type = DateType.all.last + 10
    assert !@resource_date.save
  end

  # year
  test 'year should be valid' do
    @resource_date.date_type = DateType::SINGLE

    @resource_date.year = 99999
    assert !@resource_date.save

    @resource_date.year = -99999
    assert !@resource_date.save

    @resource_date.year = Time.now.year
    assert @resource_date.save

    @resource_date.year = -9999
    assert @resource_date.save
  end

  # month
  test 'month should be valid' do
    @resource_date.date_type = DateType::SINGLE
    @resource_date.year = 1950

    @resource_date.month = 13
    assert !@resource_date.save

    @resource_date.month = 0
    assert !@resource_date.save

    @resource_date.month = 1
    assert @resource_date.save
  end

  # day
  test 'day should be valid' do
    @resource_date.date_type = DateType::SINGLE
    @resource_date.year = 1950
    @resource_date.month = 2

    @resource_date.day = 32
    assert !@resource_date.save

    @resource_date.day = 0
    assert !@resource_date.save

    @resource_date.day = 1
    assert @resource_date.save
  end

  # begin_year
  test 'begin_year should be valid' do
    @resource_date.begin_year = 99999
    assert !@resource_date.save

    @resource_date.begin_year = -99999
    assert !@resource_date.save

    @resource_date.begin_year = 1900
    assert @resource_date.save

    @resource_date.begin_year = -9999
    assert @resource_date.save
  end

  # begin_month
  test 'begin_month should be valid' do
    @resource_date.begin_month = 13
    assert !@resource_date.save

    @resource_date.begin_month = 0
    assert !@resource_date.save

    @resource_date.begin_month = 1
    assert @resource_date.save
  end

  # begin_day
  test 'begin_day should be valid' do
    @resource_date.begin_day = 32
    assert !@resource_date.save

    @resource_date.begin_day = 0
    assert !@resource_date.save

    @resource_date.begin_day = 1
    assert @resource_date.save
  end

  # end_year
  test 'end_year should be valid' do
    @resource_date.end_year = 99999
    assert !@resource_date.save

    @resource_date.end_year = -99999
    assert !@resource_date.save

    @resource_date.end_year = Time.now.year
    assert @resource_date.save

    @resource_date.begin_year = -9999
    @resource_date.end_year = -9998
    assert @resource_date.save
  end

  # end_month
  test 'end_month should be valid' do
    @resource_date.end_month = 13
    assert !@resource_date.save

    @resource_date.end_month = 0
    assert !@resource_date.save

    @resource_date.end_month = 1
    assert @resource_date.save
  end

  # end_day
  test 'end_day should be valid' do
    @resource_date.end_day = 32
    assert !@resource_date.save

    @resource_date.end_day = 0
    assert !@resource_date.save

    @resource_date.end_day = 1
    assert @resource_date.save
  end

  test 'end date should be later than begin date' do
    @resource_date.begin_year = 1920
    @resource_date.begin_month = 1
    @resource_date.begin_day = 1
    @resource_date.end_year = 1918
    @resource_date.end_month = 3
    @resource_date.end_day = 5
    assert !@resource_date.save

    @resource_date.begin_year = 1920
    @resource_date.begin_month = 5
    @resource_date.begin_day = 3
    @resource_date.end_year = 1922
    @resource_date.end_month = 1
    @resource_date.end_day = 1
    assert @resource_date.save
  end

  # resource
  test 'resource is required' do
    @resource_date.resource = nil
    assert !@resource_date.save
  end

  ############################# method tests #################################

  # as_dublin_core_string
  test 'as_dublin_core_string should work' do
    @resource_date = resource_dates(:single_date)
    assert_equal '1950-1-1', @resource_date.as_dublin_core_string

    @resource_date = resource_dates(:bulk_date)
    @resource_date.date_type = DateType::BULK
    assert_equal '1930-1-1/1960-1-1', @resource_date.as_dublin_core_string
  end

  # readable_date_type
  test 'readable_date_type should work' do
    @resource_date.date_type = DateType::SINGLE
    assert_equal 'Single', @resource_date.readable_date_type

    @resource_date.date_type = DateType::BULK
    assert_equal 'Bulk', @resource_date.readable_date_type

    @resource_date.date_type = DateType::SPAN
    assert_equal 'Span', @resource_date.readable_date_type
  end

  ########################### association tests ##############################

  # none

end
