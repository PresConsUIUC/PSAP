require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def setup
    @request.env['HTTP_REFERER'] = 'http://localhost:3000/'
  end

  #### confirm ####

  test 'attempting to confirm a nonexistent user should return 404' do
    assert_raises(ActiveRecord::RecordNotFound) do
      get :confirm, username: 'adsfasdfasfd'
      assert_response :missing
    end
  end

  test 'attempting to confirm a confirmed user should redirect to signin page' do
    get :confirm, username: 'normal'
    assert_redirected_to signin_url
  end

  test 'attempting to confirm a user with no confirmation code should redirect to signin page' do
    users(:normal_user).confirmation_code = nil
    users(:normal_user).save!
    get :confirm, username: 'normal'
    assert_redirected_to signin_url
  end

  test 'attempting to confirm a user with incorrect confirmation code provided should redirect to signin page' do
    users(:normal_user).confirmation_code = 'cats'
    users(:normal_user).save!
    get :confirm, { username: 'normal', code: 'adfsfasf' }
    assert_redirected_to signin_url
  end

  test 'attempting to confirm a user should work' do
    user = users(:normal_user)
    user.confirmation_code = 'cats'
    user.confirmed = false
    user.enabled = false
    user.save!
    get :confirm, { username: 'normal', code: 'cats' }

    user = User.find_by_username 'normal'
    assert user.confirmed
    assert user.enabled
    assert_nil user.confirmation_code
    assert_equal 'Your account has been confirmed. Please sign in.',
                 flash[:success]
    assert_redirected_to signin_url
  end

  #### edit ####

  test 'signed-out users cannot edit any users' do
    get :edit, username: 'normal'
    assert_redirected_to signin_url
  end

  test 'signed-in users can edit themselves' do
    signin_as(users(:normal_user))
    get :edit, username: 'normal'
    assert_response :success
  end

  test 'signed-in users can\'t edit other users' do
    signin_as(users(:normal_user))
    get :edit, username: 'disabled'
    assert_redirected_to root_url
  end

  test 'admin users can edit anyone' do
    signin_as(users(:admin_user))
    get :edit, username: 'disabled'
    assert_response :success
  end

  test 'attempting to edit a nonexistent user should return 404' do
    signin_as(users(:admin_user))
    assert_raises(ActiveRecord::RecordNotFound) do
      get :edit, username: 'adsfasdfasfd'
      assert_response :missing
    end
  end

  #### enable ####

  test 'signed-out users cannot enable any users' do
    patch :enable, username: 'normal'
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot enable any users' do
    signin_as(users(:normal_user))
    patch :enable, username: 'normal'
    assert_redirected_to root_url
  end

  test 'admin users can enable users' do
    users(:normal_user).enabled = false
    users(:normal_user).save!

    signin_as(users(:admin_user))
    patch :enable, username: 'normal'

    assert User.find_by_username('normal').enabled
    assert_equal 'User normal enabled.', flash[:success]
    assert_response :redirect
  end

  #### disable ####

  test 'signed-out users cannot disable any users' do
    patch :enable, username: 'normal'
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot disable any users' do
    signin_as(users(:normal_user))
    patch :enable, username: 'normal'
    assert_redirected_to root_url
  end

  test 'admin users can disable users' do
    users(:normal_user).enabled = true
    users(:normal_user).save!

    signin_as(users(:admin_user))
    patch :disable, username: 'normal'

    assert !User.find_by_username('normal').enabled
    assert_equal 'User normal disabled.', flash[:success]
    assert_response :redirect
  end

  #### exists ####

  test 'exists returns 200 for existing user' do
    get :exists, username: 'normal'
    assert_response :success
  end

  test 'exists returns 404 for nonexisting user' do
    get :exists, username: 'adsfasdfasfd'
    assert_response :missing
  end

  #### index ####

  test 'signed-out users cannot view the user list' do
    get :index
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot view the user list' do
    signin_as(users(:normal_user))
    get :index
    assert_redirected_to root_url
  end

  test 'admin users can view the user list' do
    signin_as(users(:admin_user))
    get :index
    assert_response :success
    assert_not_nil assigns :users
  end

  test 'adding a query parameter should filter the user list' do
    signin_as(users(:admin_user))

    get :index
    assert_operator assigns(:users).length, :>, 3

    get :index, { q: 'norm' }
    assert_equal 1, assigns(:users).length

    get :index, { q: 'dsfasdfasdfasdfasfd' }
    assert_equal 0, assigns(:users).length
  end

  #### show ####

  test 'signed-out users cannot view any users' do
    get :show, username: 'normal'
    assert_redirected_to signin_url
  end

  test 'signed-in users can view their own institutions\' users' do
    signin_as(users(:normal_user))
    get :show, username: 'admin'
    assert_response :success
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:resources)
  end

  test 'signed-in users cannot view other institutions\' users' do
    signin_as(users(:normal_user))
    get :show, username: 'disabled'
    assert_redirected_to root_url
  end

  test 'admin users can view other institutions\' users' do
    signin_as(users(:admin_user))
    get :show, username: 'disabled'
    assert_response :success
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:resources)
  end

  test 'attempting to view a nonexistent user returns 404' do
    signin_as(users(:normal_user))
    assert_raises(ActiveRecord::RecordNotFound) do
      get :show, username: 'adsfasdfasfd'
      assert_response :missing
    end
  end

end
