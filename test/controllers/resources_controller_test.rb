require 'test_helper'

class ResourcesControllerTest < ActionController::TestCase

  #### create ####

  test 'signed-out users cannot create resources' do
    assert_no_difference 'Resource.count' do
      res = resources(:sears_catalog_collection).attributes
      res['id'] = nil
      res['name'] = 'New Resource'
      post :create, params: { resource: res,
                              location_id: locations(:secret).id }
      assert_redirected_to signin_url
    end
  end

  test 'normal users cannot create resources in other institutions' do
    signin_as(users(:normal))
    assert_no_difference 'Resource.count' do
      res = resources(:sears_catalog_collection).attributes
      res['id'] = nil
      res['name'] = 'New Resource'
      post :create, params: { resource: res,
                              location_id: locations(:side_room).id }
      assert_redirected_to root_url
    end
  end

  test 'normal users can create resources in their own institution' do
    signin_as(users(:normal))
    assert_difference 'Resource.count' do
      res = resources(:sears_catalog_collection).attributes
      res['id'] = nil
      res['name'] = 'New Resource'
      post :create, params: { resource: res,
                              location_id: locations(:secret).id }, xhr: true
      assert_response :success
      assert_equal 'Resource "New Resource" created.',
                   flash['success']
    end
  end

  test 'admin users can create resources in any institution' do
    signin_as(users(:admin))
    assert_difference 'Resource.count' do
      res = resources(:sears_catalog_collection).attributes
      res['id'] = nil
      res['name'] = 'New Resource'
      post :create, params: { resource: res,
                              location_id: locations(:back_room).id }, xhr: true
      assert_response :success
      assert_equal 'Resource "New Resource" created.',
                   flash['success']
    end
  end

  test 'creating an invalid resource should render error template' do
    signin_as(users(:normal))
    assert_no_difference 'Resource.count' do
      res = resources(:sears_catalog_collection).attributes
      res['id'] = nil
      res['name'] = ''
      post :create, params: { resource: res,
                              location_id: locations(:secret).id }, xhr: true
    end
    assert_template :'shared/_error_messages'
  end

  #### destroy ####

  test 'signed-out users cannot destroy resources' do
    assert_no_difference 'Resource.count' do
      delete :destroy, params: { id: resources(:dead_sea_scrolls).id }
    end
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot destroy other institutions\' resources' do
    signin_as(users(:normal))
    assert_no_difference 'Resource.count' do
      delete :destroy, params: { id: resources(:cat_fancy_issue_1).id }
    end
    assert_redirected_to root_url
  end

  test 'signed-in users can destroy their own institutions\' resources' do
    signin_as(users(:normal))
    assert_difference 'Resource.count', -1 do
      delete :destroy, params: { id: resources(:magna_carta).id }
      assert_redirected_to location_url(resources(:magna_carta).location_id)
    end
  end

  test 'admin users can destroy any institutions\' resources' do
    signin_as(users(:admin))
    assert_difference 'Resource.count', -1 do
      delete :destroy, params: { id: resources(:dead_sea_scrolls).id }
    end
    assert_equal "Resource \"#{resources(:dead_sea_scrolls).name}\" deleted.",
                 flash['success']
    assert_redirected_to location_url(resources(:dead_sea_scrolls).location_id)
  end

  #### edit ####

  test 'signed-out users cannot view any edit-resource pages' do
    get :edit, params: { id: resources(:sears_catalog_collection).id }
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot view other institutions\' resource edit pages' do
    signin_as(users(:normal))
    get :edit, params: { id: resources(:sears_catalog_collection).id }
    assert_redirected_to root_url
  end

  test 'signed-in users can view their own institution\'s resource edit pages' do
    signin_as(users(:normal))
    get :edit, params: { id: resources(:magna_carta).id }, xhr: true
    assert_response :success
    assert_not_nil assigns(:resource)
  end

  test 'admin users can view any resource\'s edit page' do
    signin_as(users(:admin))
    get :edit, params: { id: resources(:cat_fancy_issue_1).id }, xhr: true
    assert_response :success
    assert_not_nil assigns(:resource)
  end

  test 'attempting to view a nonexistent resource\'s edit page returns 404' do
    signin_as(users(:normal))
    assert_raises(ActiveRecord::RecordNotFound) do
      get :edit, params: { id: 999999 }
      assert_response :missing
    end
  end

  #### new ####

  test 'signed-out users cannot view new-resource page' do
    get :new, params: { location_id: locations(:secret).id }
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot view new-resource page for other institutions' do
    signin_as(users(:normal))
    get :new, params: { location_id: locations(:back_room).id }
    assert_redirected_to root_url
  end

  test 'signed-in users can view new-resource page for their own institution' do
    signin_as(users(:normal))
    get :new, params: { location_id: locations(:secret).id }, xhr: true
    assert :success
    assert_template :'resources/_edit_form'
  end

  test 'admin users can view new-resource page for any institution' do
    signin_as(users(:admin))
    get :new, params: { location_id: locations(:side_room).id }, xhr: true
    assert :success
    assert_template :'resources/_edit_form'
  end

  #### show ####

  test 'signed-out users cannot view any resources' do
    get :show, params: { id: resources(:cat_fancy_collection).id }
    assert_redirected_to signin_url
  end

  test 'signed-in users can view their own institutions\' resources' do
    signin_as(users(:normal))
    get :show, params: { id: resources(:magna_carta).id }
    assert_response :success
    assert_not_nil assigns(:resource)
  end

  test 'signed-in users cannot view other institutions\' resources' do
    signin_as(users(:normal))
    get :show, params: { id: resources(:sears_catalog_collection).id }
    assert_redirected_to root_url
  end

  test 'admin users can view other institutions\' resources' do
    signin_as(users(:admin))
    get :show, params: { id: resources(:sears_catalog_collection).id }
    assert_response :success
    assert_not_nil assigns(:resource)
  end

  test 'attempting to view a nonexistent resource returns 404' do
    signin_as(users(:normal))
    assert_raises(ActiveRecord::RecordNotFound) do
      get :show, params: { id: 999999 }
      assert_response :missing
    end
  end

  test 'Dublin Core XML export representation is valid' do
    signin_as(users(:admin))

    xsd = Nokogiri::XML::Schema(File.read('test/controllers/oai_dc.xsd'))

    resources.each do |res|
      get :show, params: { id: res.id, format: :dcxml }
      doc = Nokogiri::XML(@response.body)
      xsd.validate(doc).each do |error|
        puts "Resource ID #{res.id}: #{error.message}"
      end
      assert xsd.valid?(doc)
    end
  end

  test 'EAD export representation is valid' do
    signin_as(users(:admin))

    xsd = Nokogiri::XML::Schema(File.read('test/controllers/ead.xsd'))

    resources.each do |res|
      get :show, params: { id: res.id, format: :ead }
      doc = Nokogiri::XML(@response.body)
      xsd.validate(doc).each do |error|
        puts "Resource ID #{res.id}: #{error.message}"
      end
      assert xsd.valid?(doc)
    end
  end

  #### update ####

  test 'signed-out users cannot update resources' do
    id = resources(:magna_carta).id
    patch :update, params: {
        resource: {
            name: 'New Name'
        },
        id: id
    }
    assert_not_equal 'New Name', Resource.find(id).name
    assert_redirected_to signin_url
  end

  test 'normal users cannot update resources in other institutions' do
    id = resources(:baseball_cards).id
    signin_as(users(:normal))
    patch :update, params: {
        resource: {
            name: 'New Name'
        },
        id: id
    }
    assert_not_equal 'New Name', Resource.find(id).name
    assert_redirected_to root_url
  end

  test 'normal users can update resources in their own institution' do
    id = resources(:magna_carta).id
    signin_as(users(:normal))
    patch :update, params: {
        resource: {
            name: 'New Name'
        },
        id: id
    }, xhr: true
    resource = Resource.find(id)
    assert_equal 'New Name', resource.name
    assert_response :success
  end

end
