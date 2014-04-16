require 'test_helper'

class RepositoriesControllerTest < ActionController::TestCase

  #### create ####

  test 'signed-out users cannot create repositories' do
    assert_no_difference 'Repository.count' do
      post :create, repository: { name: 'Test Repository' },
           institution_id: 1
    end
    assert_redirected_to signin_url
  end

  test 'normal users cannot create repositories in other institutions' do
    signin_as(users(:normal_user))
    assert_no_difference 'Repository.count' do
      post :create, repository: { name: 'Test Repository' },
           institution_id: 4
    end
    assert_redirected_to root_url
  end

  test 'normal users can create repositories in their own institutions' do
    signin_as(users(:normal_user))
    assert_difference 'Repository.count' do
      post :create, repository: { name: 'Test Repository' },
           institution_id: 1
    end
    assert_equal 'Repository "Test Repository" created.', flash[:success]
    assert_redirected_to repository_url(assigns(:repository))
  end

  test 'admin users can create repositories in any institution' do
    signin_as(users(:admin_user))
    assert_difference 'Repository.count' do
      post :create, repository: { name: 'Test Repository' },
           institution_id: 5
    end
    assert_equal 'Repository "Test Repository" created.', flash[:success]
    assert_redirected_to repository_url(assigns(:repository))
  end

  test 'creating a repository should write to the event log' do
    signin_as(users(:admin_user))
    assert_difference 'Event.count' do
      post :create, repository: { name: 'Test Repository' },
           institution_id: 5
    end
  end

  test 'creating an invalid repository should render new template' do
    signin_as(users(:normal_user))
    assert_no_difference 'Repository.count' do
      post :create, repository: { name: '' },
           institution_id: 1
    end
    assert_template :new
  end

  #### destroy ####

  test 'signed-out users cannot destroy repositories' do
    assert_no_difference 'Repository.count' do
      delete :destroy, id: 2
    end
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot destroy other institutions\' repositories' do
    signin_as(users(:normal_user))
    assert_no_difference 'Repository.count' do
      delete :destroy, id: 3
    end
    assert_redirected_to root_url
  end

  test 'signed-in users can destroy their own institutions\' repositories' do
    signin_as(users(:normal_user))
    assert_difference 'Repository.count', -1 do
      delete :destroy, id: repositories(:repository_one).id
      assert_redirected_to institution_url(institutions(:institution_one).id)
    end
  end

  test 'admin users can destroy any institutions\' repositories' do
    signin_as(users(:admin_user))
    assert_difference 'Repository.count', -1 do
      delete :destroy, id: repositories(:repository_two).id
    end
    assert_equal "Repository \"#{repositories(:repository_two).name}\" deleted.",
                 flash[:success]
    assert_redirected_to institution_url(institutions(:institution_two).id)
  end

  test 'destoying a repository should write to the event log' do
    signin_as(users(:admin_user))
    assert_difference 'Event.count' do
      delete :destroy, id: repositories(:repository_two).id
    end
  end

  #### edit ####

  test 'signed-out users cannot view any edit-repository pages' do
    get :edit, id: 3
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot view other institutions\' repository edit pages' do
    signin_as(users(:normal_user))
    get :edit, id: 3
    assert_redirected_to root_url
  end

  test 'signed-in users can view their own institution\'s repository edit pages' do
    signin_as(users(:normal_user))
    get :edit, id: 1
    assert_response :success
    assert_not_nil assigns(:repository)
  end

  test 'admin users can view any repository\'s edit page' do
    signin_as(users(:admin_user))
    get :edit, id: 5
    assert_response :success
    assert_not_nil assigns(:repository)
  end

  test 'attempting to view a nonexistent repository\'s edit page returns 404' do
    signin_as(users(:normal_user))
    assert_raises(ActiveRecord::RecordNotFound) do
      get :edit, id: 999999
      assert_response :missing
    end
  end

  #### new ####

  test 'signed-out users cannot view new-repository page' do
    get :new, institution_id: 1
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot view new-repository page for other institutions' do
    signin_as(users(:normal_user))
    get :new, institution_id: 3
    assert_redirected_to root_url
  end

  test 'signed-in users can view new-repository page for their own institution' do
    signin_as(users(:normal_user))
    get :new, institution_id: 1
    assert :success
    assert_not_nil assigns(:institution)
    assert_not_nil assigns(:repository)
    assert_template :new
  end

  test 'admin users can view new-repository page for any institution' do
    signin_as(users(:admin_user))
    get :new, institution_id: 5
    assert :success
    assert_not_nil assigns(:institution)
    assert_not_nil assigns(:repository)
    assert_template :new
  end

  #### show ####

  test 'signed-out users cannot view any repositories' do
    get :show, id: 3
    assert_redirected_to signin_url
  end

  test 'signed-in users can view their own repositories' do
    signin_as(users(:normal_user))
    get :show, id: 1
    assert_response :success
    assert_not_nil assigns(:repository)
  end

  test 'signed-in users cannot view other institutions\' repositories' do
    signin_as(users(:normal_user))
    get :show, id: 3
    assert_redirected_to root_url
  end

  test 'admin users can view any repository' do
    signin_as(users(:admin_user))
    get :show, id: 5
    assert_response :success
    assert_not_nil assigns(:repository)
  end

  test 'attempting to view a nonexistent repository returns 404' do
    signin_as(users(:normal_user))
    assert_raises(ActiveRecord::RecordNotFound) do
      get :show, id: 999999
      assert_response :missing
    end
  end

  #### update ####

  test 'signed-out users cannot update repositories' do
    patch :update, repository: { name: 'New Name' }, id: 1
    assert_not_equal 'New Name', Repository.find(1).name
    assert_redirected_to signin_url
  end

  test 'normal users cannot update repositories in other institutions' do
    signin_as(users(:normal_user))
    patch :update, repository: { name: 'New Name' }, id: 4
    assert_not_equal 'New Name', Repository.find(4).name
    assert_redirected_to root_url
  end

  test 'normal users can update repositories in their own institutions' do
    signin_as(users(:normal_user))
    patch :update, repository: { name: 'New Name' }, id: 1
    assert_equal 'New Name', Repository.find(1).name
    assert_redirected_to repository_url(assigns(:repository))
  end

  test 'admin users can update repositories in any institution' do
    signin_as(users(:admin_user))
    patch :update, repository: { name: 'New Name' }, id: 5
    assert_equal 'New Name', Repository.find(5).name
    assert_redirected_to repository_url(assigns(:repository))
  end

  test 'updating a repository should write to the event log' do
    signin_as(users(:admin_user))
    assert_difference 'Event.count' do
      patch :update, repository: { name: 'New Name' }, id: 5
    end
  end

end
