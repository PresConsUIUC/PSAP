require 'test_helper'

class DashboardControllerTest < ActionController::TestCase

  #### index ####

  test 'signed-out users are redirected to sign-in url' do
    get :index
    assert_redirected_to signin_url
  end

  test 'signed-in users can view the dashboard' do
    signin_as(users(:normal_user))
    get :index
    assert_response :success
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:resources)
  end

  test 'affiliated users have necessary ivars set' do
    signin_as(users(:normal_user))
    get :index
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:resources)
    assert_not_nil assigns(:institution_users)
    assert_not_nil assigns(:recent_assessments)
  end

  test 'unaffiliated users\' necessary ivars are nil' do
    signin_as(users(:unaffiliated_user))
    get :index
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:resources)
    assert_nil assigns(:institution_users)
    assert_nil assigns(:recent_assessments)
  end

  test 'signed-out users cannot view the dashboard feed' do
    get :index, format: :atom
    assert_redirected_to signin_url
  end

  test 'signed-in users can view the dashboard feed' do
    signin_as(users(:normal_user))
    get :index, format: :atom
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:events)
  end

  test 'atom feed representation is valid' do
    signin_as(users(:normal_user))

    require 'nokogiri'
    xsd = Nokogiri::XML::Schema(File.read('test/controllers/atom.xsd'))

    get :index, format: :atom

    doc = Nokogiri::XML(@response.body)
    xsd.validate(doc).each do |error|
      puts error.message
    end

    assert xsd.valid?(doc)
  end

end
