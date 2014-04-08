require 'test_helper'

class InstitutionTest < ActiveSupport::TestCase

  setup :setup

  protected

  def setup
    @default_values = {name: 'Test', address1: 'Test', address2: 'Test',
                       city: 'Test', state: 'Test', postal_code: 'Test',
                       country: 'Test', url: 'http://example.org/',
                       description: 'Test'}
    @institution = Institution.new(@default_values)
  end

  ############################ object tests #################################

  test 'editing generates an event log entry' do
    @institution.save! # hasn't been saved yet
    @institution.name = 'blabla'
    @institution.save!
    assert_equal 'Edited institution blabla', Event.last.description
  end

  test 'deleting generates an event log entry' do
    @institution.save! # hasn't been saved yet
    @institution.destroy!
    assert_equal 'Deleted institution Test', Event.last.description
  end

  ########################### property tests ################################

  # name
  test 'name is required' do
    @institution.name = nil
    assert !@institution.save
  end

  test 'name must be at least 4 characters' do
    @institution.name = 'abc'
    assert !@institution.save
  end

  test 'name is case-insensitively unique' do
    assert @institution.save

    inst2 = Institution.new(@default_values)
    inst2.name = inst2.name.upcase
    assert !inst2.save
  end

  # address1
  test 'address1 is required' do
    @institution.address1 = nil
    assert !@institution.save
  end

  test 'address2 is optional' do
    @institution.address2 = nil
    assert @institution.save
  end

  # city
  test 'city is required' do
    @institution.city = nil
    assert !@institution.save
  end

  # state
  test 'state is required' do
    @institution.state = nil
    assert !@institution.save
  end

  test 'state is no longer than 30 characters' do
    @institution.state = 'a' * 31
    assert !@institution.save
  end

  # postal code
  test 'postal code is required' do
    @institution.postal_code = nil
    assert !@institution.save
  end

  test 'postal code is no longer than 30 characters' do
    @institution.postal_code = 'a' * 31
    assert !@institution.save
  end

  # country
  test 'country is required' do
    @institution.country = nil
    assert !@institution.save
  end

  # url
  test 'url is optional' do
    @institution.url = nil
    assert @institution.save
  end

  test 'url must be a url' do
    @institution.url = 'abc'
    assert !@institution.save
  end

end
