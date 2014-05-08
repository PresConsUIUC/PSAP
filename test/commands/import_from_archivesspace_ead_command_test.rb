require 'test_helper'

class ImportFromArchivesspaceEadCommandTest < ActiveSupport::TestCase

  def setup
    @user = users(:normal_user)
    @remote_ip = '10.0.0.1'

    @valid_params = { host: 'http://www.example.com/', password: 'password',
                      port: 80, resource_id: 1, username: 'username' }
    @valid_command = ImportFromArchivesspaceEadCommand.new(@valid_params, @user,
                                                           @remote_ip)

    @invalid_params = @valid_params.dup.except(:host)
    @invalid_command = ImportFromArchivesspaceEadCommand.new(@invalid_params,
                                                             @user, @remote_ip)
  end

  # execute

  # get_session_token
  test 'get_session_token should raise an exception if login failed' do
    flunk
  end

  test 'get_session_token should raise an exception if given an invalid host' do
    flunk
  end

  test 'get_session_token should get a session token if login succeeded' do
    flunk
  end

  # get_ead
  test 'get_ead should raise an exception if given an invalid session token' do
    flunk
  end

  test 'get_ead should raise an exception if given an invalid resource ID' do
    flunk
  end

  test 'get_ead should raise an exception if given an invalid host' do
    flunk
  end

  test 'get_ead should retrieve EAD of valid resource' do
    flunk
  end

  # resource_attributes_from_ead
  test 'resource_attributes_from_ead should raise an exception if given invalid XML' do
    assert_raises REXML::ParseException do
      @valid_command.resource_attributes_from_ead('<cats></cat', users(:normal_user).id)
    end
  end

  test 'resource_attributes_from_ead should raise an exception if given an invalid user ID' do
    assert_raises RuntimeError do
      @valid_command.resource_attributes_from_ead('<?xml version="1.0" ?><cats></cats>',
                                                  999999999)
    end
  end

  test 'resource_attributes_from_ead should return correct resource attributes' do
    xml = File.read('test/commands/archivesspace_ead_export.xml')
    attrs = @valid_command.resource_attributes_from_ead(xml, users(:normal_user).id)

    assert_nil attrs[:description]
    assert_nil attrs[:format_id]
    assert_equal '15.31.26', attrs[:local_identifier]
    assert_nil attrs[:location_id]
    assert_equal 'Mandeville Collection', attrs[:name]
    assert_nil attrs[:notes]
    assert_equal 0, attrs[:resource_type]
    assert_equal 1, attrs[:user_id]
    assert_equal 'Davis, Michael J., 1942-', attrs[:creators_attributes][0][:name]
    assert_equal '229 Photographic Prints', attrs[:extents_attributes][0][:name]
    assert_equal '5 boxes, 2 oversized boxes, 8 oversized folders',
                 attrs[:extents_attributes][1][:name]
    assert_equal 1, attrs[:resource_dates_attributes][0][:date_type]
    assert_equal 1965, attrs[:resource_dates_attributes][0][:begin_year]
    assert_equal 1985, attrs[:resource_dates_attributes][0][:end_year]
    assert_equal 'fix this', attrs[:subjects_attributes]
  end

  # object
  test 'object method should return the created ArchivesspaceImport object' do
    assert_kind_of ArchivesspaceImport, @valid_command.object
  end

  # created_resource
  test 'execute method should populate the created_resource method' do
    @valid_command.execute
    assert_kind_of Resource, @valid_command.created_resource
  end

end
