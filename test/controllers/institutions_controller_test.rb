require 'test_helper'

class InstitutionsControllerTest < ActionController::TestCase

  #### create ####

  test 'signed-out users cannot create institutions' do
    assert_no_difference 'Institution.count' do
      inst = institutions(:three).attributes
      inst[:id] = nil
      inst[:name] = 'New Institution'
      post :create, params: { institution: inst }
    end
    assert_redirected_to signin_url
  end

  test 'normal users can create institutions' do
    signin_as(users(:normal))
    assert_difference 'Institution.count' do
      inst = institutions(:three).attributes
      inst[:id] = nil
      inst[:name] = 'New Institution'
      post :create, params: { institution: inst }, xhr: true
    end
    assert_response :success
  end

  test 'admin users can create institutions' do
    signin_as(users(:admin))
    assert_difference 'Institution.count' do
      inst = institutions(:three).attributes
      inst[:id] = nil
      inst[:name] = 'New Institution'
      post :create, params: { institution: inst }, xhr: true
    end
    assert_response :success
  end

  test 'creating an invalid institution should render new template' do
    signin_as(users(:normal))
    assert_no_difference 'Institution.count' do
      inst = institutions(:three).attributes
      inst[:id] = nil
      inst[:name] = ''
      post :create, params: { institution: inst }, xhr: true
    end
    assert_template :'shared/_error_messages'
  end

  #### destroy ####

  test 'signed-out users cannot destroy institutions' do
    assert_no_difference 'Institution.count' do
      delete :destroy, params: { id: institutions(:two).id }
    end
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot destroy institutions' do
    signin_as(users(:normal))
    assert_no_difference 'Institution.count' do
      delete :destroy, params: { id: institutions(:one).id }
    end
    assert_redirected_to root_url
  end

  test 'admin users cannot destroy institutions containing users' do
    institution = institutions(:one)
    signin_as(users(:admin))
    assert_no_difference 'Institution.count' do
      delete :destroy, params: { id: institution.id }
    end
    assert_equal "The institution \"University of Illinois at "\
    "Urbana-Champaign\" cannot be deleted, as there are one or more users "\
    "affiliated with it.", flash['error']
    assert_redirected_to institution
  end

  test 'admin users can destroy institutions containing no users' do
    signin_as(users(:admin))
    assert_difference 'Institution.count', -1 do
      delete :destroy, params: { id: institutions(:five).id }
    end
    assert_equal "Institution \"#{institutions(:five).name}\" deleted.",
                 flash['success']
    assert_redirected_to institutions_path
  end

  #### edit ####

  test 'signed-out users cannot view any institution edit pages' do
    get :edit, params: { id: institutions(:three).id }
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot view other institutions\' edit pages' do
    signin_as(users(:normal))
    get :edit, params: { id: institutions(:three).id }
    assert_redirected_to root_url
  end

  test 'signed-in users can view their own institutions\' edit pages' do
    signin_as(users(:normal))
    get :edit, params: { id: institutions(:one).id }, xhr: true
    assert_response :success
  end

  test 'admin users can view any institution\'s edit page' do
    signin_as(users(:admin))
    get :edit, params: { id: institutions(:five).id }, xhr: true
    assert_response :success
  end

  test 'attempting to view a nonexistent institution\'s edit page returns 404' do
    signin_as(users(:normal))
    assert_raises(ActiveRecord::RecordNotFound) do
      get :edit, params: { id: 999999 }
      assert_response :missing
    end
  end

  #### new ####

  test 'signed-out users cannot view new-institution page' do
    get :new
    assert_redirected_to signin_url
  end

  test 'signed-in users can view new-institution page' do
    signin_as(users(:normal))
    get :new, xhr: true
    assert :success
    assert_template :'institutions/_edit_form'
  end

  test 'admin users can view new-institution page' do
    signin_as(users(:admin))
    get :new, xhr: true
    assert :success
    assert_template :'institutions/_edit_form'
  end

  #### show ####

  test 'signed-out users cannot view any institutions' do
    get :show, params: { id: institutions(:three).id }
    assert_response :redirect
  end

  test 'signed-in users can view their own institution' do
    signin_as(users(:normal))
    get :show, params: { id: institutions(:one).id }
    assert_response :success
  end

  test 'signed-in users cannot view other institutions' do
    signin_as(users(:normal))
    get :show, params: { id: institutions(:three).id }
    assert_redirected_to root_url
  end

  test 'admin users can view any institution' do
    signin_as(users(:admin))
    get :show, params: { id: institutions(:five).id }
    assert_response :success
  end

  test 'attempting to view a nonexistent institution returns 404' do
    signin_as(users(:normal))
    assert_raises(ActiveRecord::RecordNotFound) do
      get :show, params: { id: 999999 }
      assert_response :missing
    end
  end

  #### update ####

  test 'signed-out users cannot update institutions' do
    id = institutions(:three).id
    inst = institutions(:three).attributes
    inst[:id] = nil
    inst[:name] = 'New Name'
    patch :update, params: { institution: inst, id: id }, xhr: true
    assert_not_equal 'New Name', Institution.find(id).name
    assert_redirected_to signin_url
  end

  test 'normal users cannot update other institutions' do
    signin_as(users(:normal))
    id = institutions(:three).id
    inst = institutions(:three).attributes
    inst[:id] = nil
    inst[:name] = 'New Name'
    patch :update, params: { institution: inst, id: id }, xhr: true
    assert_not_equal 'New Name', Institution.find(id).name
    assert_redirected_to root_url
  end

  test 'normal users can update their own institution' do
    signin_as(users(:normal))
    id = institutions(:one).id
    inst = institutions(:one).attributes
    inst[:id] = nil
    inst[:name] = 'New Name'
    patch :update, params: { institution: inst, id: id }, xhr: true
    assert_response :success
    assert_equal 'New Name', Institution.find(id).name
  end

  test 'admin users can update any institution' do
    signin_as(users(:admin))
    id = institutions(:three).id
    inst = institutions(:three).attributes
    inst[:id] = nil
    inst[:name] = 'New Name'
    patch :update, params: { institution: inst, id: id }, xhr: true
    assert_response :success
    assert_equal 'New Name', Institution.find(id).name
  end

end
