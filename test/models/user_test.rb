require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = users(:normal_user)
  end

  ######################### class method tests ##############################

  test 'most_active should work' do
    most_active = User.most_active
    assert_equal 1, most_active.length
    assert_equal 4, most_active[0][:count]
    assert_kind_of User, most_active[0][:user]
  end

  ############################ object tests #################################

  test 'setup generates a confirmation code' do
    user = User.new(users(:normal_user).attributes)
    user.confirmation_code = 'cats'
    assert_equal 'cats', user.confirmation_code
  end

  test 'valid user saves' do
    assert @user.save
  end

  ########################### property tests ################################

  # email
  test 'email is required' do
    @user.email = nil
    assert !@user.save
  end

  test 'email is case-insensitively unique' do
    @user.save

    user2 = users(:unaffiliated_user)
    user2.email = @user.email.upcase
    assert !user2.save
  end

  test 'email is downcased on save' do
    @user.email = 'TEST@EXAMPLE.ORG'
    @user.save
    assert_equal 'test@example.org', @user.email
  end

  # first_name
  test 'first_name is required' do
    @user.first_name = nil
    assert !@user.save
  end

  # last_name
  test 'last_name is required' do
    @user.last_name = nil
    assert !@user.save
  end

  # password
  test 'password is not required' do
    @user.password = nil
    @user.password_confirmation = nil
    assert @user.save
  end

  test 'password should be a minimum of 6 characters' do
    @user.password = 'abcde'
    @user.password_confirmation = 'abcde'
    assert !@user.save
  end

  # role
  test 'role is required' do
    @user.role = nil
    assert !@user.save
  end

  # username
  test 'username is required' do
    @user.username = nil
    assert !@user.save
  end

  test 'username is case-insensitively unique' do
    @user.save
    user2 = users(:unaffiliated_user)
    user2.username = @user.username.upcase
    assert !user2.save
  end

  ############################ method tests #################################

  # full_name
  test 'full name is correct' do
    assert_equal "#{@user.first_name} #{@user.last_name}", @user.full_name
  end

  # has_permission
  test 'has_permission should work' do
    assert_equal @user.role.has_permission?('cats'),
                 @user.has_permission?('cats')
  end

  # is_admin?
  test 'is_admin? should work' do
    assert_equal @user.role.is_admin?, @user.is_admin?
  end

end
