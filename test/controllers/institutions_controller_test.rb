require 'test_helper'

class InstitutionsControllerTest < ActionController::TestCase

  #### create ####

  test 'signed-out users cannot create institutions' do
    assert_no_difference 'Institution.count' do
      inst = institutions(:institution_three).attributes
      inst[:id] = nil
      inst[:name] = 'New Institution'
      post :create, institution: inst
    end
    assert_redirected_to signin_url
  end

  test 'normal users can create institutions' do
    signin_as(users(:normal_user))
    assert_difference 'Institution.count' do
      inst = institutions(:institution_three).attributes
      inst[:id] = nil
      inst[:name] = 'New Institution'
      post :create, institution: inst
    end
    assert_redirected_to dashboard_url
  end

  test 'admin users can create institutions' do
    signin_as(users(:admin_user))
    assert_difference 'Institution.count' do
      inst = institutions(:institution_three).attributes
      inst[:id] = nil
      inst[:name] = 'New Institution'
      post :create, institution: inst
    end
    assert_redirected_to institution_url(assigns(:institution))
  end

  test 'creating an institution should write to the event log' do
    signin_as(users(:admin_user))
    assert_difference 'Event.count' do
      inst = institutions(:institution_three).attributes
      inst[:id] = nil
      inst[:name] = 'New Institution'
      post :create, institution: inst
    end
  end

  test 'creating an invalid institution should render new template' do
    signin_as(users(:normal_user))
    assert_no_difference 'Institution.count' do
      inst = institutions(:institution_three).attributes
      inst[:id] = nil
      inst[:name] = ''
      post :create, institution: inst
    end
    assert_template :new
  end

  #### destroy ####

  test 'signed-out users cannot destroy institutions' do
    assert_no_difference 'Institution.count' do
      delete :destroy, id: 2
    end
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot destroy institutions' do
    signin_as(users(:normal_user))
    assert_no_difference 'Institution.count' do
      delete :destroy, id: 1
    end
    assert_redirected_to root_url
  end

  test 'admin users cannot destroy institutions containing users' do
    institution = institutions(:institution_one)
    signin_as(users(:admin_user))
    assert_no_difference 'Institution.count' do
      delete :destroy, id: institution.id
    end
    assert_equal "The institution \"University of Illinois at "\
    "Urbana-Champaign\" cannot be deleted, as there are one or more users "\
    "affiliated with it.", flash[:error]
    assert_redirected_to institution
  end

  test 'admin users can destroy institutions containing no users' do
    signin_as(users(:admin_user))
    assert_difference 'Institution.count', -1 do
      delete :destroy, id: institutions(:institution_five).id
    end
    assert_equal "Institution \"#{institutions(:institution_five).name}\" deleted.",
                 flash[:success]
    assert_redirected_to institutions_path
  end

  test 'destroying an institution should write to the event log' do
    signin_as(users(:admin_user))
    assert_difference 'Event.count' do
      delete :destroy, id: institutions(:institution_five).id
    end
  end

  #### edit ####

  test 'signed-out users cannot view any institution edit pages' do
    get :edit, id: 3
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot view other institutions\' edit pages' do
    signin_as(users(:normal_user))
    get :edit, id: 3
    assert_redirected_to root_url
  end

  test 'signed-in users can view their own institutions\' edit pages' do
    signin_as(users(:normal_user))
    get :edit, id: 1
    assert_response :success
    assert_not_nil assigns(:institution)
  end

  test 'admin users can view any institution\'s edit page' do
    signin_as(users(:admin_user))
    get :edit, id: 5
    assert_response :success
    assert_not_nil assigns(:institution)
  end

  test 'attempting to view a nonexistent institution\'s edit page returns 404' do
    signin_as(users(:normal_user))
    assert_raises(ActiveRecord::RecordNotFound) do
      get :edit, id: 999999
      assert_response :missing
    end
  end

  #### new ####

  test 'signed-out users cannot view new-institution page' do
    get :new
    assert_redirected_to signin_url
  end

  test 'signed-in users can view new-institution page' do
    signin_as(users(:normal_user))
    get :new
    assert :success
    assert_not_nil assigns(:institution)
    assert_template :new
  end

  test 'admin users can view new-institution page' do
    signin_as(users(:admin_user))
    get :new
    assert :success
    assert_not_nil assigns(:institution)
    assert_template :new
  end

  #### show ####

  test 'signed-out users cannot view any institutions' do
    get :show, id: 3
    assert_response :redirect
  end

  test 'signed-in users can view their own institution' do
    signin_as(users(:normal_user))
    get :show, id: 1
    assert_response :success
    assert_not_nil assigns(:institution)
    assert_not_nil assigns(:repositories)
  end

  test 'signed-in users cannot view other institutions' do
    signin_as(users(:normal_user))
    get :show, id: 3
    assert_redirected_to root_url
  end

  test 'admin users can view any institution' do
    signin_as(users(:admin_user))
    get :show, id: 5
    assert_response :success
    assert_not_nil assigns(:institution)
    assert_not_nil assigns(:repositories)
  end

  test 'attempting to view a nonexistent institution returns 404' do
    signin_as(users(:normal_user))
    assert_raises(ActiveRecord::RecordNotFound) do
      get :show, id: 999999
      assert_response :missing
    end
  end

  #### update ####

  test 'signed-out users cannot update institutions' do
    inst = institutions(:institution_three).attributes
    inst[:id] = nil
    inst[:name] = 'New Name'
    patch :update, institution: inst, id: 1
    assert_not_equal 'New Name', Institution.find(1).name
    assert_redirected_to signin_url
  end

  test 'normal users cannot update other institutions' do
    signin_as(users(:normal_user))
    inst = institutions(:institution_three).attributes
    inst[:id] = nil
    inst[:name] = 'New Name'
    patch :update, institution: inst, id: 4
    assert_not_equal 'New Name', Institution.find(4).name
    assert_redirected_to root_url
  end

  test 'normal users can update their own institution' do
    signin_as(users(:normal_user))
    inst = institutions(:institution_three).attributes
    inst[:id] = nil
    inst[:name] = 'New Name'
    patch :update, institution: inst, id: 1
    assert_equal 'New Name', Institution.find(1).name
    assert_redirected_to institution_url(assigns(:institution))
  end

  test 'admin users can update any institution' do
    signin_as(users(:admin_user))
    inst = institutions(:institution_three).attributes
    inst[:id] = nil
    inst[:name] = 'New Name'
    patch :update, institution: inst, id: 3
    assert_equal 'New Name', Institution.find(3).name
    assert_redirected_to institution_url(assigns(:institution))
  end

  test 'updating an institution should write to the event log' do
    signin_as(users(:admin_user))
    assert_difference 'Event.count' do
      inst = institutions(:institution_three).attributes
      inst[:id] = nil
      inst[:name] = 'New Name'
      patch :update, institution: inst, id: 3
    end
  end

end
