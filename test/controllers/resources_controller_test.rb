require 'test_helper'

class ResourcesControllerTest < ActionController::TestCase

  #### show ####

  test 'signed-out users cannot view any resources' do
    get :show, id: 7
    assert_response :redirect
  end

  test 'signed-in users can view their own institutions\' resources' do
    signin_as(users(:normal_user))
    get :show, id: 1
    assert_response :success
    assert_not_nil assigns(:resource)
  end

  test 'signed-in users cannot view other institutions\' resources' do
    signin_as(users(:normal_user))
    get :show, id: 3
    assert_response :redirect
  end

  test 'admin users can view other institutions\' resources' do
    signin_as(users(:admin_user))
    get :show, id: 3
    assert_response :success
    assert_not_nil assigns(:resource)
  end

  test 'attempting to view a nonexistent resource returns 404' do
    signin_as(users(:normal_user))
    assert_raises(ActiveRecord::RecordNotFound) do
      get :show, id: 999999
      assert_response :missing
    end
  end

  test 'EAD export representation is valid' do
    signin_as(users(:admin_user))
    get :show, id: 7, format: :xml

    require 'nokogiri'
    xsd = Nokogiri::XML::Schema(File.read('test/controllers/ead.xsd'))
    doc = Nokogiri::XML(@response.body)

    xsd.validate(doc).each do |error|
      puts error.message
    end

    assert xsd.valid?(doc)
  end

end
