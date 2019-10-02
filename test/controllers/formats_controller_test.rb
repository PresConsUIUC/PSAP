require 'test_helper'

# The post/patch methods don't like posting "format" as a hash, which causes
# some of these tests to fail.
class FormatsControllerTest < ActionController::TestCase

  #### index ####

  test 'signed-out users cannot view the format list' do
    get :index
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot view the format list' do
    signin_as(users(:normal))
    get :index
    assert_redirected_to root_url
  end

  test 'signed-in users can get the format list via JSON' do
    signin_as(users(:normal))
    get :index, params: { format: :json }
    assert_response :success
  end

  test 'admin users can view the format list' do
    signin_as(users(:admin))
    get :index
    assert_response :success
    assert_not_nil assigns :formats
  end

  #### show ####

  test 'signed-out users cannot view any formats' do
    get :show, params: { id: formats(:used_napkin).id }
    assert_redirected_to signin_url
  end

  test 'signed-in users cannot view any formats' do
    signin_as(users(:normal))
    get :show, params: { id: formats(:used_napkin).id }
    assert_redirected_to root_url
  end

  test 'admin users can view formats' do
    signin_as(users(:admin))
    get :show, params: { id: formats(:used_napkin).id }
    assert_response :success
    assert_not_nil assigns :format
    assert_template :show
  end

  test 'attempting to view a nonexistent format returns 404' do
    signin_as(users(:admin))
    assert_raises(ActiveRecord::RecordNotFound) do
      get :show, params: { id: 999999 }
      assert_response :missing
    end
  end

end
