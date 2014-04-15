require 'test_helper'

class ResourcesControllerTest < ActionController::TestCase

  #### create ####

  test 'signed-out users cannot create resources' do
    assert_no_difference 'Resource.count' do
      res = resources(:resource_three).attributes
      res[:id] = nil
      res[:name] = 'New Resource'
      post :create, resource: res, location_id: 1
    end
    assert_redirected_to signin_url
  end

  test 'normal users cannot create resources in other institutions' do
    signin_as(users(:normal_user))
    assert_no_difference 'Resource.count' do
      res = resources(:resource_three).attributes
      res[:id] = nil
      res[:name] = 'New Resource'
      post :create, resource: res, location_id: 5
    end
    assert_redirected_to root_url
  end

  test 'normal users can create resources in their own institution' do
    signin_as(users(:normal_user))
    assert_difference 'Resource.count' do
      res = resources(:resource_three).attributes
      res[:id] = nil
      res[:name] = 'New Resource'
      post :create, resource: res, location_id: 1
    end
    assert_equal 'Resource "New Resource" created.', flash[:success]
    assert_redirected_to resource_url(assigns(:resource))
  end

  test 'admin users can create resources in any institution' do
    signin_as(users(:admin_user))
    assert_difference 'Resource.count' do
      res = resources(:resource_three).attributes
      res[:id] = nil
      res[:name] = 'New Resource'
      post :create, resource: res, location_id: 3
    end
    assert_equal 'Resource "New Resource" created.', flash[:success]
    assert_redirected_to resource_url(assigns(:resource))
  end

  test 'creating an invalid resource should render new template' do
    signin_as(users(:normal_user))
    assert_no_difference 'Resource.count' do
      res = resources(:resource_three).attributes
      res[:id] = nil
      res[:name] = ''
      post :create, resource: res, location_id: 1
    end
    assert_template :new
  end

  #### destroy ####

  test 'signed-out users cannot destroy resources' do
    assert_no_difference 'Resource.count' do
      delete :destroy, id: 2
    end
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot destroy other institutions\' resources' do
    signin_as(users(:normal_user))
    assert_no_difference 'Resource.count' do
      delete :destroy, id: 8
    end
    assert_redirected_to root_url
  end

  test 'signed-in users can destroy their own institutions\' resources' do
    signin_as(users(:normal_user))
    assert_difference 'Resource.count', -1 do
      delete :destroy, id: resources(:resource_one).id
      assert_redirected_to location_url(resources(:resource_one).location_id)
    end
  end

  test 'admin users can destroy any institutions\' resources' do
    signin_as(users(:admin_user))
    assert_difference 'Resource.count', -1 do
      delete :destroy, id: resources(:resource_two).id
    end
    assert_equal "Resource \"#{resources(:resource_two).name}\" deleted.",
                 flash[:success]
    assert_redirected_to location_url(resources(:resource_two).location_id)
  end

  #### edit ####

  test 'signed-out users cannot view any edit-resource pages' do
    get :edit, id: 3
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot view other institutions\' resource edit pages' do
    signin_as(users(:normal_user))
    get :edit, id: 3
    assert_redirected_to root_url
  end

  test 'signed-in users can view their own institution\'s resource edit pages' do
    signin_as(users(:normal_user))
    get :edit, id: 1
    assert_response :success
    assert_not_nil assigns(:resource)
  end

  test 'admin users can view any resource\'s edit page' do
    signin_as(users(:admin_user))
    get :edit, id: 8
    assert_response :success
    assert_not_nil assigns(:resource)
  end

  test 'attempting to view a nonexistent resource\'s edit page returns 404' do
    signin_as(users(:normal_user))
    assert_raises(ActiveRecord::RecordNotFound) do
      get :edit, id: 999999
      assert_response :missing
    end
  end

  #### new ####

  test 'signed-out users cannot view new-resource page' do
    get :new, location_id: 1
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot view new-resource page for other institutions' do
    signin_as(users(:normal_user))
    get :new, location_id: 3
    assert_redirected_to root_url
  end

  test 'signed-in users can view new-resource page for their own institution' do
    signin_as(users(:normal_user))
    get :new, location_id: 1
    assert :success
    assert_not_nil assigns(:location)
    assert_not_nil assigns(:resource)
    assert_template :new
  end

  test 'admin users can view new-resource page for any institution' do
    signin_as(users(:admin_user))
    get :new, location_id: 5
    assert :success
    assert_not_nil assigns(:location)
    assert_not_nil assigns(:resource)
    assert_template :new
  end

  #### show ####

  test 'signed-out users cannot view any resources' do
    get :show, id: 7
    assert_redirected_to signin_url
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
    assert_redirected_to root_url
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

    require 'nokogiri'
    xsd = Nokogiri::XML::Schema(File.read('test/controllers/ead.xsd'))

    resources.each do |res|
      get :show, id: 7, format: :xml

      doc = Nokogiri::XML(@response.body)
      xsd.validate(doc).each do |error|
        puts "Resource ID #{res.id}: #{error.message}"
      end

      assert xsd.valid?(doc)
    end
  end

  #### update ####

  test 'signed-out users cannot update resources' do
    patch :update, resource: { name: 'New Name' }, id: 1
    assert_not_equal 'New Name', Resource.find(1).name
    assert_redirected_to signin_url
  end

  test 'normal users cannot update resources in other institutions' do
    signin_as(users(:normal_user))
    patch :update, resource: { name: 'New Name' }, id: 4
    assert_not_equal 'New Name', Resource.find(4).name
    assert_redirected_to root_url
  end

  test 'normal users can update resources in their own institution' do
    signin_as(users(:normal_user))
    patch :update, resource: { name: 'New Name' }, id: 1
    assert_equal 'New Name', Resource.find(1).name
    assert_redirected_to resource_url(assigns(:resource))
  end

  test 'admin users can update repositories in any institution' do
    signin_as(users(:admin_user))
    patch :update, resource: { name: 'New Name' }, id: 5
    assert_equal 'New Name', Resource.find(5).name
    assert_redirected_to resource_url(assigns(:resource))
  end

end
