require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def setup
    @request.env['HTTP_REFERER'] = 'http://localhost:3000/'
  end

  #### create ####

  test 'users can be created' do
    assert_difference 'User.count' do
      post :create, user: { username: 'newuser', email: 'newuser@example.org',
                            first_name: 'New', last_name: 'User',
                            password: 'password',
                            password_confirmation: 'password' }
    end
    assert_equal 'Thanks for registering for PSAP! An email has been '\
        'sent to the address you provided. Follow the link in the email to '\
        'confirm your account.', flash[:success]
    assert_equal 'User', assigns(:user).role.name
    assert_redirected_to root_url
  end

  test 'creating an invalid user should render new template' do
    assert_no_difference 'User.count' do
      post :create, user: { first_name: 'New', email: '',
                            last_name: 'User', password: 'password',
                            password_confirmation: '',
                            username: 'newuser' }
    end
    assert_template :new
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

  #### destroy ####

  test 'signed-out users cannot destroy users' do
    assert_no_difference 'User.count' do
      delete :destroy, username: 'normal'
    end
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot destroy users' do
    signin_as(users(:normal_user))
    assert_no_difference 'User.count' do
      delete :destroy, username: 'normal'
    end
    assert_redirected_to root_url
  end

  test 'admin users can destroy users' do
    signin_as(users(:admin_user))
    assert_difference 'User.count', -1 do
      delete :destroy, username: users(:normal_user).username
    end
    assert_equal "User #{users(:normal_user).username} deleted.",
                 flash[:success]
    assert_redirected_to users_url
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

  #### new ####

  test 'should get new user page' do
    get :new
    assert_not_nil assigns(:user)
    assert_response :success
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

  #### update ####

  test 'signed-out users cannot update users' do
    patch :update, user: { username: 'newuser', email: 'newuser@example.org',
                           first_name: 'New', last_name: 'User',
                           password: 'password',
                           password_confirmation: 'password' },
          username: 'normal'
    assert_not_equal 'newuser', User.find(1).username
    assert_redirected_to signin_url
  end

  test 'normal users cannot update other users' do
    signin_as(users(:normal_user))
    patch :update, user: { username: 'newuser', email: 'newuser@example.org',
                           first_name: 'New', last_name: 'User',
                           password: 'password',
                           password_confirmation: 'password' },
          username: 'unaffiliated'
    assert_not_equal 'newuser', User.find(1).username
    assert_redirected_to root_url
  end

  test 'normal users can update themselves' do
    signin_as(users(:normal_user))
    patch :update, user: { username: 'normal', email: 'normal@example.org',
                           first_name: 'New', last_name: 'User',
                           password: 'password',
                           password_confirmation: 'password' },
          username: 'normal'
    assert_equal 'New', User.find(1).first_name
    assert_equal 'Your profile has been updated.', flash[:success]
    assert_redirected_to edit_user_url(assigns(:user))
  end

  test 'updating users with invalid data renders edit template' do
    signin_as(users(:normal_user))
    patch :update, user: { first_name: '', last_name: '',
                           password: 'asfdasfdasfd',
                           password_confirmation: 'zcvxcvzvx' },
          username: 'normal'
    assert_equal 'Norm', users(:normal_user).first_name
    assert_template :edit
  end

  test 'users cannot change their username' do
    signin_as(users(:normal_user))
    patch :update, user: { username: 'newuser', email: 'normal@example.org',
                           first_name: 'New', last_name: 'User',
                           password: 'password',
                           password_confirmation: 'password' },
          username: 'normal'
    assert_nil User.find_by_username 'newuser'
    assert_redirected_to edit_user_url(assigns(:user))
  end

  test 'changing email address sends an email confirmation' do
    signin_as(users(:normal_user))
    assert_difference('ActionMailer::Base.deliveries.size', 1) do
      patch :update, user: { username: 'normal', email: 'newemail@example.org',
                             first_name: 'New', last_name: 'User',
                             password: 'password',
                             password_confirmation: 'password' },
            username: 'normal'
    end
  end

  test 'admin users can update other users' do
    signin_as(users(:admin_user))
    patch :update, user: { username: 'unaffiliated', email: 'newuser@example.org',
                           first_name: 'New', last_name: 'User',
                           password: 'password',
                           password_confirmation: 'password' },
          username: 'unaffiliated'
    assert_equal 'New', User.find_by_username('unaffiliated').first_name
    assert_equal 'unaffiliated\'s profile has been updated.', flash[:success]
    assert_redirected_to edit_user_url(assigns(:user))
  end

  test 'admin users can change other users\' username' do
    signin_as(users(:admin_user))
    patch :update, user: { username: 'newusername', email: 'newuser@example.org',
                           first_name: 'New', last_name: 'User',
                           password: 'password',
                           password_confirmation: 'password' },
          username: 'unaffiliated'
    assert_not_nil User.find_by_username 'newusername'
    assert_redirected_to edit_user_url(assigns(:user))
  end

  test 'admin users can change their own username' do
    signin_as(users(:admin_user))
    patch :update, user: { username: 'newusername', email: 'newuser@example.org',
                           first_name: 'New', last_name: 'User',
                           password: 'password',
                           password_confirmation: 'password' },
          username: 'admin'
    assert_not_nil User.find_by_username 'newusername'
    assert_redirected_to edit_user_url(assigns(:user))
  end

  test 'joining an institution for the first time should work' do
    signin_as(users(:unaffiliated_user))
    patch :update, user: { institution_id: 3 },
          username: 'unaffiliated'
    assert_equal 'You are now a member of Hamburger University.',
                 flash[:success]
    assert_redirected_to dashboard_url
  end

end
