require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = users(:normal)
  end

  ############################ object tests #################################

  test 'setup generates a confirmation code' do
    user = User.new(users(:normal).attributes)
    assert_not_nil user.confirmation_code
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

  test 'email must be case-insensitively unique' do
    @user.save

    user2 = users(:unaffiliated)
    user2.email = @user.email.upcase
    assert !user2.save
  end

  test 'email should be downcased on save' do
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
  test 'password is required' do
    @user.password = nil
    assert !@user.save
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
    user2 = users(:unaffiliated)
    user2.username = @user.username.upcase
    assert !user2.save
  end

  test 'username should be 20 characters or less' do
    @user.username = 'a' * 21
    assert !@user.save
  end

  ############################ method tests #################################

  # to_param
  test 'to_param should return the username' do
    assert_equal @user.username, @user.to_param
  end

  # full_name
  test 'full name is correct' do
    assert_equal "#{@user.first_name} #{@user.last_name}", @user.full_name
  end

  # has_permission?
  test 'has_permission? should work' do
    assert_equal @user.role.has_permission?('cats'),
                 @user.has_permission?('cats')
  end

  # is_admin?
  test 'is_admin? should work' do
    assert_equal @user.role.is_admin?, @user.is_admin?
  end

  # reset_password_reset_key
  test 'reset_password_reset_key should work' do
    initial = @user.reset_password_reset_key
    @user.reset_password_reset_key
    assert_not_equal @user.reset_password_reset_key, initial
  end

  ########################### association tests ##############################

  # none

end
