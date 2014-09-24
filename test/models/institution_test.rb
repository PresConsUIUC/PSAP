require 'test_helper'

class InstitutionTest < ActiveSupport::TestCase

  def setup
    @default_values = {name: 'Test', address1: 'Test', address2: 'Test',
                       city: 'Test', state: 'Test', postal_code: 'Test',
                       country: 'Test', url: 'http://example.org/',
                       description: 'Test'}
    @institution = Institution.new(@default_values)
  end

  ############################ object tests #################################

  test 'valid institution saves' do
    assert @institution.save
  end

  ######################### class method tests ##############################

  test 'most_active works' do
    flunk
    Institution.most_active
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

  ########################### dependency tests ###############################

  test 'repositories should be destroyed on destroy' do
    repo = repositories(:repository_two)
    @institution.repositories << repo
    @institution.destroy
    assert repo.destroyed?
  end

  test 'attempting to destroy an institution with users in it should raise an exception' do
    @institution = institutions(:institution_one)
    assert_raises ActiveRecord::DeleteRestrictionError do
      @institution.destroy
    end
  end

  test 'attempting to destroy an institution without users in it should work' do
    @institution = institutions(:institution_four)
    assert @institution.destroy
  end

  ############################# method tests #################################

  test 'most_active_users works' do
    flunk
    @institution.most_active_users
  end

end
