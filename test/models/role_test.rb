require 'test_helper'

class RoleTest < ActiveSupport::TestCase

  def setup
    @role = roles(:normal_role)
  end

  ######################### class method tests ##############################

  # none

  ############################ object tests #################################

  test 'valid role saves' do
    assert @role.save
  end

  ########################### property tests ################################

  # name
  test 'name is required' do
    @role.name = nil
    assert !@role.save
  end

  test 'name should be no longer than 255 characters' do
    @role.name = 'a' * 256
    assert !@role.save
  end

  test 'name must be unique' do
    role2 = Role.new(name: 'User')
    assert !role2.save
  end

  ############################# method tests #################################

  test 'has_permission? should work' do
    assert @role.has_permission?('normal_user_permission')
    assert !@role.has_permission?('cats')
  end

  ########################### association tests ##############################

  # none

end
