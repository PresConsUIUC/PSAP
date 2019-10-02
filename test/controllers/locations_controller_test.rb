require 'test_helper'

class LocationsControllerTest < ActionController::TestCase

  #### create ####

  test 'signed-out users cannot create locations' do
    assert_no_difference 'Location.count' do
      post :create, params: {
          location: {
              name: 'Test Location',
              description: 'Test Description'
          },
          repository_id: repositories(:one).id
      }
    end
    assert_redirected_to signin_url
  end

  test 'normal users cannot create locations in other institutions\' repositories' do
    signin_as(users(:normal))
    assert_no_difference 'Location.count' do
      post :create, params: {
          location: {
              name: 'Test Location',
              description: 'Test Description'
          },
          repository_id: repositories(:four).id
      }
    end
    assert_redirected_to root_url
  end

  test 'normal users can create locations in their own institutions\' repositories' do
    signin_as(users(:normal))
    assert_difference 'Location.count' do
      post :create, params: {
          location: {
              name: 'Test Location',
              description: 'Test Description'
          },
          repository_id: repositories(:one).id
      }, xhr: true
    end
    assert_equal 'Location "Test Location" created.', flash['success']
    assert_response :success
  end

  test 'admin users can create locations in any institutions\' repositories' do
    signin_as(users(:admin))
    assert_difference 'Location.count' do
      post :create, params: {
          location: {
              name: 'Test Location',
              description: 'Test Description'
          },
          repository_id: repositories(:five).id
      }, xhr: true
    end
    assert_equal 'Location "Test Location" created.', flash['success']
    assert_response :success
  end

  test 'creating an invalid location should render new template' do
    signin_as(users(:normal))
    assert_no_difference 'Location.count' do
      post :create, params: {
          location: {
              name: '',
              description: ''
          },
          repository_id: repositories(:one).id
      }, xhr: true
    end
    assert_template :'shared/_error_messages'
  end

  #### destroy ####

  test 'signed-out users cannot destroy locations' do
    assert_no_difference 'Location.count' do
      delete :destroy, params: { id: locations(:by_file_cabinet).id }
    end
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot destroy other institutions\' locations' do
    signin_as(users(:normal))
    assert_no_difference 'Location.count' do
      delete :destroy, params: { id: locations(:back_room).id }
    end
    assert_redirected_to root_url
  end

  test 'signed-in users can destroy their own institutions\' locations' do
    signin_as(users(:normal))
    assert_difference 'Location.count', -1 do
      delete :destroy, params: { id: locations(:secret).id }
      assert_redirected_to repository_url(locations(:secret).repository_id)
    end
  end

  test 'admin users can destroy any institutions\' locations' do
    signin_as(users(:admin))
    assert_difference 'Location.count', -1 do
      delete :destroy, params: { id: locations(:by_file_cabinet).id }
    end
    assert_equal "Location \"#{locations(:by_file_cabinet).name}\" deleted.",
                 flash['success']
    assert_redirected_to repository_url(locations(:by_file_cabinet).repository_id)
  end

  #### edit ####

  test 'signed-out users cannot view any edit-location pages' do
    get :edit, params: { id: locations(:back_room).id }
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot view other institutions\' location edit pages' do
    signin_as(users(:normal))
    get :edit, params: { id: locations(:back_room).id }
    assert_redirected_to root_url
  end

  test 'signed-in users can view their own locations\' edit pages' do
    signin_as(users(:normal))
    get :edit, params: { id: locations(:secret).id }, xhr: true
    assert_response :success
    assert_not_nil assigns(:location)
  end

  test 'admin users can view any location\'s edit page' do
    signin_as(users(:admin))
    get :edit, params: { id: locations(:side_room).id }, xhr: true
    assert_response :success
    assert_not_nil assigns(:location)
  end

  test 'attempting to view a nonexistent location\'s edit page returns 404' do
    signin_as(users(:normal))
    assert_raises(ActiveRecord::RecordNotFound) do
      get :edit, params: { id: 999999 }
      assert_response :missing
    end
  end

  #### new ####

  test 'signed-out users cannot view new-location page' do
    get :new, params: { repository_id: repositories(:one).id }
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot view new-location page for other institutions\' repositories' do
    signin_as(users(:normal))
    get :new, params: { repository_id: repositories(:three).id }
    assert_redirected_to root_url
  end

  test 'signed-in users can view new-location page for their own repositories' do
    signin_as(users(:normal))
    get :new, params: { repository_id: repositories(:one).id }, xhr: true
    assert :success
    assert_template :'locations/_edit_form'
  end

  test 'admin users can view new-location page for any repository' do
    signin_as(users(:admin))
    get :new, params: { repository_id: repositories(:five).id }, xhr: true
    assert :success
    assert_template :'locations/_edit_form'
  end

  #### show ####

  test 'signed-out users cannot view any locations' do
    get :show, params: { id: locations(:back_room).id }
    assert_redirected_to signin_url
  end

  test 'signed-in users can view their own locations' do
    signin_as(users(:normal))
    get :show, params: { id: locations(:secret).id }
    assert_response :success
  end

  test 'signed-in users cannot view other institutions\' locations' do
    signin_as(users(:normal))
    get :show, params: { id: locations(:back_room).id }
    assert_redirected_to root_url
  end

  test 'admin users can view any location' do
    signin_as(users(:admin))
    get :show, params: { id: locations(:front_room).id }
    assert_response :success
  end

  test 'attempting to view a nonexistent location returns 404' do
    signin_as(users(:normal))
    assert_raises(ActiveRecord::RecordNotFound) do
      get :show, params: { id: 999999 }
      assert_response :missing
    end
  end

  #### update ####

  test 'signed-out users cannot update locations' do
    id = locations(:secret).id
    patch :update, params: {
        location: {
            name: 'New Name',
            description: 'New Description'
        },
        id: id
    }
    assert_not_equal 'New Name', Location.find(id).name
    assert_redirected_to signin_url
  end

  test 'normal users cannot update locations in other institutions\' repositories' do
    id = locations(:front_room).id
    signin_as(users(:normal))
    patch :update, params: {
        location: {
            name: 'New Name',
            description: 'New Description'
        },
        id: id
    }
    assert_not_equal 'New Name', Location.find(id).name
    assert_redirected_to root_url
  end

  test 'normal users can update locations in their own institutions\' repositories' do
    id = locations(:secret).id
    signin_as(users(:normal))
    patch :update, params: {
        location: {
            name: 'New Name',
            description: 'New Description'
        },
        id: id
    }
    assert_equal 'New Name', Location.find(id).name
    assert_response :success
  end

  test 'admin users can update locations in any institutions\' repositories' do
    id = locations(:side_room).id
    signin_as(users(:admin))
    patch :update, params: {
        location: {
            name: 'New Name',
            description: 'New Description'
        },
        id: id
    }
    assert_equal 'New Name', Location.find(id).name
    assert_response :success
  end

end
