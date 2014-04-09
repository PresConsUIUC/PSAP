require 'test_helper'

class ResourceDateTest < ActiveSupport::TestCase

  def setup
    @default_values = { date_type: DateType::BULK,
                        begin_year: 1930,
                        end_year: 1960 }
    @resource_date = ResourceDate.new(@default_values)
    @resource_date.resource = resources(:resource_one)
  end

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

end
