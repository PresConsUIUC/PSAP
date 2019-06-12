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
  end

  test 'affiliated users have necessary ivars set' do
    signin_as(users(:normal_user))
    get :index
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:institution_events)
    assert_not_nil assigns(:institution_users)
    assert_not_nil assigns(:recent_updated_resources)
  end

  test 'unaffiliated users have necessary ivars are set' do
    signin_as(users(:unaffiliated_user))
    get :index
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:institutions)
  end

  test 'users cannot view a dashboard feed without a key' do
    get :index, params: { format: :atom }
    assert_response :forbidden
  end

  test 'signed-in users can view the dashboard feed' do
    feed_key = users(:normal_user).feed_key
    get :index, params: { format: :atom, key: feed_key }
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:events)
  end

  test 'atom feed representation is valid' do
    feed_key = users(:normal_user).feed_key

    require 'nokogiri'
    xsd = Nokogiri::XML::Schema(File.read('test/controllers/atom.xsd'))

    get :index, params: { format: :atom, key: feed_key }

    doc = Nokogiri::XML(@response.body)
    xsd.validate(doc).each do |error|
      puts error.message
    end

    assert xsd.valid?(doc)
  end

end
