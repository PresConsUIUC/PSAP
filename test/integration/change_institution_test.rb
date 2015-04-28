require 'test_helper'

class ChangeInstitutionTest < ActionDispatch::IntegrationTest

  setup do
    @user = users(:normal_user)
    @new_institution = institutions(:institution_two)

    @valid_username = @user.username
    @valid_password = 'password'
  end

  test 'non-admin users should not be allowed to change other users\' institution' do
    signin(@valid_username, @valid_password)
    admin_user = users(:admin_user)
    original_institution = admin_user.institution
    admin_user.desired_institution = @new_institution
    admin_user.save
    patch_via_redirect("/users/#{admin_user.username}",
                       'user' => admin_user.attributes)

    admin_user.reload
    assert_equal(admin_user.institution, original_institution)

    assert flash['error'].include?('failed')
  end

  test 'changing an institution to the same institution should fail' do
    signin(@valid_username, @valid_password)
    @user.desired_institution = @user.institution
    @user.save
    patch_via_redirect("/users/#{@user.username}",
                       'user' => @user.attributes)
    assert flash['error'].include?('failed')
  end

  test 'admin users can change institutions with no review' do
  end

  test 'non-admin user institution change requests should notify administrators' do
    signin(@valid_username, @valid_password)
    @user.desired_institution = @new_institution
    @user.save
    patch_via_redirect("/users/#{@user.username}",
                       'user' => @user.attributes)

    @user.reload
    assert_equal(@new_institution, @user.desired_institution)

    # test the flash
    assert flash['success'].include?('An administrator has been notified')

    # test that an email was sent
    email = AdminMailer.institution_change_review_request_email(@user).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [Psap::Application.config.psap_email_address], email.from
    assert_equal [Psap::Application.config.psap_email_address], email.to
    assert_equal 'PSAP user requests to change institutions', email.subject
  end

end
