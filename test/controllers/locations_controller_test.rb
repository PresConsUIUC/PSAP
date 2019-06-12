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
          repository_id: 1
      }
    end
    assert_redirected_to signin_url
  end

  test 'normal users cannot create locations in other institutions\' repositories' do
    signin_as(users(:normal_user))
    assert_no_difference 'Location.count' do
      post :create, params: {
          location: {
              name: 'Test Location',
              description: 'Test Description'
          },
          repository_id: 4
      }
    end
    assert_redirected_to root_url
  end

  test 'normal users can create locations in their own institutions\' repositories' do
    signin_as(users(:normal_user))
    assert_difference 'Location.count' do
      post :create, params: {
          location: {
              name: 'Test Location',
              description: 'Test Description'
          },
          repository_id: 1
      }, xhr: true
    end
    assert_equal 'Location "Test Location" created.', flash['success']
    assert_response :success
  end

  test 'admin users can create locations in any institutions\' repositories' do
    signin_as(users(:admin_user))
    assert_difference 'Location.count' do
      post :create, params: {
          location: {
              name: 'Test Location',
              description: 'Test Description'
          },
          repository_id: 5
      }, xhr: true
    end
    assert_equal 'Location "Test Location" created.', flash['success']
    assert_response :success
  end

  test 'creating a location should write to the event log' do
    signin_as(users(:admin_user))
    assert_difference 'Event.count' do
      post :create, params: {
          location: {
              name: 'Test Location',
              description: 'Test Description'
          },
          repository_id: 5
      }, xhr: true
    end
  end

  test 'creating an invalid location should render new template' do
    signin_as(users(:normal_user))
    assert_no_difference 'Location.count' do
      post :create, params: {
          location: {
              name: '',
              description: ''
          },
          repository_id: 1
      }, xhr: true
    end
    assert_template :'shared/_error_messages'
  end

  #### destroy ####

  test 'signed-out users cannot destroy locations' do
    assert_no_difference 'Location.count' do
      delete :destroy, params: { id: 2 }
    end
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot destroy other institutions\' locations' do
    signin_as(users(:normal_user))
    assert_no_difference 'Location.count' do
      delete :destroy, params: { id: 3 }
    end
    assert_redirected_to root_url
  end

  test 'signed-in users can destroy their own institutions\' locations' do
    signin_as(users(:normal_user))
    assert_difference 'Location.count', -1 do
      delete :destroy, params: { id: locations(:location_one).id }
      assert_redirected_to repository_url(locations(:location_one).repository_id)
    end
  end

  test 'admin users can destroy any institutions\' locations' do
    signin_as(users(:admin_user))
    assert_difference 'Location.count', -1 do
      delete :destroy, params: { id: locations(:location_two).id }
    end
    assert_equal "Location \"#{locations(:location_two).name}\" deleted.",
                 flash['success']
    assert_redirected_to repository_url(locations(:location_two).repository_id)
  end

  test 'destroying a location should write to the event log' do
    signin_as(users(:admin_user))
    assert_difference 'Event.count' do
      delete :destroy, params: { id: locations(:location_two).id }
    end
  end

  #### edit ####

  test 'signed-out users cannot view any edit-location pages' do
    get :edit, params: { id: 3 }
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot view other institutions\' location edit pages' do
    signin_as(users(:normal_user))
    get :edit, params: { id: 3 }
    assert_redirected_to root_url
  end

  test 'signed-in users can view their own locations\' edit pages' do
    signin_as(users(:normal_user))
    get :edit, params: { id: 1 }, xhr: true
    assert_response :success
    assert_not_nil assigns(:location)
  end

  test 'admin users can view any location\'s edit page' do
    signin_as(users(:admin_user))
    get :edit, params: { id: 5 }, xhr: true
    assert_response :success
    assert_not_nil assigns(:location)
  end

  test 'attempting to view a nonexistent location\'s edit page returns 404' do
    signin_as(users(:normal_user))
    assert_raises(ActiveRecord::RecordNotFound) do
      get :edit, params: { id: 999999 }
      assert_response :missing
    end
  end

  #### new ####

  test 'signed-out users cannot view new-location page' do
    get :new, params: { repository_id: 1 }
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot view new-location page for other institutions\' repositories' do
    signin_as(users(:normal_user))
    get :new, params: { repository_id: 3 }
    assert_redirected_to root_url
  end

  test 'signed-in users can view new-location page for their own repositories' do
    signin_as(users(:normal_user))
    get :new, params: { repository_id: 1 }, xhr: true
    assert :success
    assert_template :'locations/_edit_form'
  end

  test 'admin users can view new-location page for any repository' do
    signin_as(users(:admin_user))
    get :new, params: { repository_id: 5 }, xhr: true
    assert :success
    assert_template :'locations/_edit_form'
  end

  #### show ####

  test 'signed-out users cannot view any locations' do
    get :show, params: { id: 3 }
    assert_redirected_to signin_url
  end

  test 'signed-in users can view their own locations' do
    signin_as(users(:normal_user))
    get :show, params: { id: 1 }
    assert_response :success
  end

  test 'signed-in users cannot view other institutions\' locations' do
    signin_as(users(:normal_user))
    get :show, params: { id: 3 }
    assert_redirected_to root_url
  end

  test 'admin users can view any location' do
    signin_as(users(:admin_user))
    get :show, params: { id: 5 }
    assert_response :success
  end

  test 'attempting to view a nonexistent location returns 404' do
    signin_as(users(:normal_user))
    assert_raises(ActiveRecord::RecordNotFound) do
      get :show, params: { id: 999999 }
      assert_response :missing
    end
  end

  #### update ####

  test 'signed-out users cannot update locations' do
    patch :update, params: {
        location: {
            name: 'New Name',
            description: 'New Description'
        },
        id: 1
    }
    assert_not_equal 'New Name', Location.find(1).name
    assert_redirected_to signin_url
  end

  test 'normal users cannot update locations in other institutions\' repositories' do
    signin_as(users(:normal_user))
    patch :update, params: {
        location: {
            name: 'New Name',
            description: 'New Description'
        },
        id: 4
    }
    assert_not_equal 'New Name', Location.find(4).name
    assert_redirected_to root_url
  end

  test 'normal users can update locations in their own institutions\' repositories' do
    signin_as(users(:normal_user))
    patch :update, params: {
        location: {
            name: 'New Name',
            description: 'New Description'
        },
        id: 1
    }
    assert_equal 'New Name', Location.find(1).name
    assert_response :success
  end

  test 'admin users can update locations in any institutions\' repositories' do
    signin_as(users(:admin_user))
    patch :update, params: {
        location: {
            name: 'New Name',
            description: 'New Description'
        },
        id: 5
    }
    assert_equal 'New Name', Location.find(5).name
    assert_response :success
  end

  test 'updating a location should write to the event log' do
    signin_as(users(:admin_user))
    assert_difference 'Event.count' do
      patch :update, params: {
          location: {
              name: 'New Name',
              description: 'New Description'
          },
          id: 5
      }
    end
  end

end
