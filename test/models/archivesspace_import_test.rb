require 'test_helper'

class ArchivesspaceImportTest < ActiveSupport::TestCase

  def setup
    @import = ArchivesspaceImport.new(host: 'localhost', password: 'password',
                                      port: 80, resource_id: 1,
                                      username: 'username')
  end

  ############################ object tests #################################

  test 'valid ArchivesspaceImport is valid' do
    assert @import.valid?
  end

  ########################### property tests ################################

  # host
  test 'host is required' do
    @import.host = nil
    assert !@import.valid?
  end

  # password
  test 'password is required' do
    @import.password = nil
    assert !@import.valid?
  end

  # port
  test 'port is not required' do
    @import.port = nil
    assert @import.valid?
  end

  test 'port should be between 1 and 65536' do
    @import.port = 592
    assert @import.valid?

    @import.port = -2
    assert !@import.valid?

    @import.port = 592529
    assert !@import.valid?
  end

  # resource_id
  test 'resource_id is required' do
    @import.resource_id = nil
    assert !@import.valid?
  end

  # username
  test 'username is required' do
    @import.username = nil
    assert !@import.valid?
  end

end
