require 'test_helper'

class InstitutionTest < ActiveSupport::TestCase

  def setup
    @institution = institutions(:institution_one)
  end

  ######################### class method tests ##############################

  test 'most_active works' do
    most_active = Institution.most_active
    assert_equal 1, most_active.length
    assert_equal 4, most_active[0][:count]
    assert_kind_of Institution, most_active[0][:institution]
  end

  ############################ object tests #################################

  test 'valid institution saves' do
    assert @institution.save
  end

  test 'assessment score is updated before save' do
    flunk # TODO: write this
  end

  ########################### property tests ################################

  # address1
  test 'address1 is required' do
    @institution.address1 = nil
    assert !@institution.save
  end

  test 'address1 should be no more than 255 characters' do
    @institution.address1 = 'a' * 256
    assert !@institution.save
  end

  test 'address2 is optional' do
    @institution.address2 = nil
    assert @institution.save
  end

  test 'address2 should be no more than 255 characters' do
    @institution.address2 = 'a' * 256
    assert !@institution.save
  end

  # city
  test 'city is required' do
    @institution.city = nil
    assert !@institution.save
  end

  test 'city should be no more than 255 characters' do
    @institution.city = 'a' * 256
    assert !@institution.save
  end

  # name
  test 'name is required' do
    @institution.name = nil
    assert !@institution.save
  end

  test 'name must be at least 4 characters' do
    @institution.name = 'abc'
    assert !@institution.save
  end

  test 'name should be no more than 255 characters' do
    @institution.name = 'a' * 256
    assert !@institution.save
  end

  test 'name is case-insensitively unique' do
    inst2 = Institution.new(name: @institution.name.upcase)
    assert !inst2.save
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

  test 'country should be no more than 255 characters' do
    @institution.country = 'a' * 256
    assert !@institution.save
  end

  # url
  test 'url is optional' do
    @institution.url = nil
    assert @institution.save
  end

  test 'url should be a url' do
    @institution.url = 'abc'
    assert !@institution.save
  end

  ############################# method tests #################################

  test 'most_active_users works' do
    @institution.id = 1
    most_active = @institution.most_active_users
    assert_equal 1, most_active.length
    assert_equal 4, most_active[0][:count]
    assert_kind_of User, most_active[0][:user]
  end

  test 'resources_as_csv works' do
    flunk # TODO: write this
  end

  ########################### association tests ##############################

  test 'assessment question responses should be destroyed on destroy' do
    @institution.users.destroy_all
    response = assessment_question_responses(:assessment_question_response_one)
    @institution.assessment_question_responses << response
    @institution.destroy
    assert response.destroyed?
  end

  test 'repositories should be destroyed on destroy' do
    @institution.users.destroy_all
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

end
