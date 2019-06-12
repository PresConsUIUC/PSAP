require 'test_helper'

class EventsControllerTest < ActionController::TestCase

  test 'non-admin users cannot view the index page' do
    signin_as(users(:normal_user))
    get :index
    assert_redirected_to root_url
  end

  test 'signed-out users cannot view the index page' do
    get :index
    assert_redirected_to signin_url
  end

  test 'admin users should get the index page' do
    signin_as(users(:admin_user))
    get :index
    assert_response :success
    assert_not_nil assigns :events
    assert_not_nil assigns :event_level
  end

  test 'adding a query parameter should filter the event list' do
    signin_as(users(:admin_user))

    get :index
    assert_operator assigns(:events).length, :>, 0

    get :index, params: { q: 'warning' }
    assert_equal 1, assigns(:events).length

    get :index, params: { q: 'dsfasdfasdfasdfasfd' }
    assert_equal 0, assigns(:events).length
  end

  test 'signed-out users cannot view the events feed' do
    get :index, params: { format: :atom }
    assert_response :forbidden
  end

  test 'non-admin users cannot view the events feed' do
    signin_as(users(:normal_user))
    get :index, params: { format: :atom }
    assert_response :forbidden
  end

  test 'admin users can view the events feed' do
    feed_key = users(:admin_user).feed_key
    get :index, params: { format: :atom, key: feed_key }
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:events)
    assert_not_nil assigns(:event_level)
  end

  test 'atom feed representation should be valid' do
    feed_key = users(:admin_user).feed_key

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
