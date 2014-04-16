require 'test_helper'

# TODO: The post/patch methods don't seem to like posting "format" as a hash,
# which causes some of these tests to fail.
class FormatsControllerTest < ActionController::TestCase

  #### create ####

  test 'signed-out users cannot create formats' do
    assert_no_difference 'Format.count' do
      post :create, format: { name: 'Test Format', score: 0.5, obsolete: 1 }
    end
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot create formats' do
    signin_as(users(:normal_user))
    assert_no_difference 'Format.count' do
      post :create, format: { name: 'Test Format', score: 0.5, obsolete: 1 }
    end
    assert_redirected_to root_url
  end

  test 'admin users can create formats' do
    signin_as(users(:admin_user))
    assert_difference 'Format.count' do
      post :create, format: { name: 'Test Format', score: 0.5, obsolete: 1 }
    end
    assert_equal 'The format "Test Format" has been created.', flash[:success]
    assert_redirected_to formats_url
  end

  test 'creating a format should write to the event log' do
    signin_as(users(:admin_user))
    assert_difference 'Event.count' do
      post :create, format: { name: 'Test Format', score: 0.5, obsolete: 1 }
    end
  end

  test 'creating an invalid format should render new template' do
    signin_as(users(:admin_user))
    assert_no_difference 'Format.count' do
      post :create, format: { name: 'Test Format', score: -5, obsolete: 1 }
    end
    assert_template :new
  end

  #### destroy ####

  test 'signed-out users cannot destroy formats' do
    assert_no_difference 'Format.count' do
      delete :destroy, id: 2
    end
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot destroy formats' do
    signin_as(users(:normal_user))
    assert_no_difference 'Format.count' do
      delete :destroy, id: 2
    end
    assert_redirected_to root_url
  end

  test 'admin users can destroy formats' do
    signin_as(users(:admin_user))
    assert_difference 'Format.count', -1 do
      delete :destroy, id: formats(:format_two).id
    end
    assert_equal "Format \"#{formats(:format_two).name}\" deleted.",
                 flash[:success]
    assert_redirected_to formats_url
  end

  test 'destroying a format should write to the event log' do
    signin_as(users(:admin_user))
    assert_difference 'Event.count' do
      delete :destroy, id: formats(:format_two).id
    end
  end

  #### edit ####

  test 'signed-out users cannot edit formats' do
    assert_no_difference 'Format.count' do
      get :edit, id: 2
    end
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot edit formats' do
    signin_as(users(:normal_user))
    assert_no_difference 'Format.count' do
      get :edit, id: 2
    end
    assert_redirected_to root_url
  end

  test 'admin users can edit formats' do
    signin_as(users(:admin_user))
    get :edit, id: 2
    assert_response :success
    assert_not_nil assigns(:format)
    assert_template :edit
  end

  test 'editing a nonexistent format shows 404' do
    signin_as(users(:admin_user))
    assert_raises(ActiveRecord::RecordNotFound) do
      get :edit, id: 999999
      assert_response :missing
    end
  end

  #### index ####

  test 'signed-out users cannot view the format list' do
    get :index
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot view the format list' do
    signin_as(users(:normal_user))
    get :index
    assert_redirected_to root_url
  end

  test 'admin users can view the format list' do
    signin_as(users(:admin_user))
    get :index
    assert_response :success
    assert_not_nil assigns :formats
  end

  test 'adding a query parameter should filter the format list' do
    signin_as(users(:admin_user))

    get :index
    assert_operator assigns(:formats).length, :>, 3

    get :index, { q: 'post-it' }
    assert_equal 1, assigns(:formats).length

    get :index, { q: 'dsfasdfasdfasdfasfd' }
    assert_equal 0, assigns(:formats).length
  end

  #### new ####

  test 'signed-out users cannot access new format page' do
    get :new
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot access new format page' do
    signin_as(users(:normal_user))
    get :new
    assert_redirected_to root_url
  end

  test 'admin users can access new format page' do
    signin_as(users(:admin_user))
    get :new
    assert_response :success
    assert_not_nil assigns(:format)
    assert_template :new
  end

  #### show ####

  test 'signed-out users cannot view any formats' do
    get :show, id: 1
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot view any formats' do
    signin_as(users(:normal_user))
    get :show, id: 1
    assert_redirected_to root_url
  end

  test 'admin users can view formats' do
    signin_as(users(:admin_user))
    get :show, id: 1
    assert_response :success
    assert_not_nil assigns :format
    assert_template :show
  end

  test 'attempting to view a nonexistent format returns 404' do
    signin_as(users(:admin_user))
    assert_raises(ActiveRecord::RecordNotFound) do
      get :show, id: 999999
      assert_response :missing
    end
  end

  #### update ####

  test 'signed-out users cannot update formats' do
    patch :update, id: 1, format: { name: 'New Name',
                                    score: 0.5, obsolete: 1 }
    assert_not_equal 'New Name', Format.find(1).name
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot update formats' do
    signin_as(users(:normal_user))
    patch :update, id: 1, format: { name: 'New Name',
                                    score: 0.5, obsolete: 1 }
    assert_not_equal 'New Name', Location.find(1).name
    assert_redirected_to root_url
  end

  test 'admin users can update formats' do
    signin_as(users(:admin_user))
    patch :update, id: 1, format: { name: 'New Name',
                                    score: 0.5, obsolete: 1 }
    assert_response :success
    assert_equal 'Format "Test Format" updated.', flash[:success]
    assert_equal 'New Name', Location.find(1).name
    assert_redirected_to format_url(assigns(:format))
  end

  test 'updating a format should write to the event log' do
    signin_as(users(:admin_user))
    assert_difference 'Event.count' do
      patch :update, id: 1, format: { name: 'New Name',
                                      score: 0.5, obsolete: 1 }
    end
  end

  test 'updating a format with invalid parameters should render edit template' do
    signin_as(users(:admin_user))
    patch :update, id: 1, format: { score: 2.2 }
    assert_not_equal 2.2, Location.find(1).score
    assert_template :edit
  end

end
