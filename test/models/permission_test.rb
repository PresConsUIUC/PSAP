require 'test_helper'

class PermissionTest < ActiveSupport::TestCase

  def setup
    @permission = permissions(:one)
  end

  ######################### class method tests ##############################

  # none

  ############################ object tests #################################

  test 'valid permissions can be created' do
    assert Permission.create(key: 'test')
  end

  test 'permissions are read-only once created' do
    permission = Permission.create(key: 'test')
    permission.key = 'test2'
    assert_raises ActiveRecord::ReadOnlyRecord do
      assert !permission.save
      assert !permission.destroy
    end
  end

  ########################### property tests ################################

  # key
  test 'key is required' do
    @permission.key = nil
    assert !@permission.save
  end

  ############################# method tests #################################

  # none

  ########################### association tests ##############################

  # none

end
