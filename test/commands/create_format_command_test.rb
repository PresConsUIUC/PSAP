require 'test_helper'

class CreateFormatCommandTest < ActiveSupport::TestCase

  def setup
    @valid_params = formats(:format_one).attributes
    @valid_params['id'] = nil
    @valid_params['name'] = 'asdfasfd'
    @user = users(:normal_user)
    @remote_ip = '10.0.0.1'
    @valid_command = CreateFormatCommand.new(@valid_params, @user, @remote_ip)

    @invalid_params = @valid_params.dup.except('name')
    @invalid_command = CreateFormatCommand.new(@invalid_params, @user,
                                               @remote_ip)
  end

  # execute
  test 'execute method should save format if valid' do
    assert_nothing_raised do
      assert_difference 'Event.count' do
        @valid_command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "Created format \"#{@valid_command.object.name}\"",
                 event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'execute method should fail if validation failed' do
    assert_raises ValidationError do
      assert_difference 'Event.count' do
        @invalid_command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "Attempted to create format, but failed: Name can't be blank",
                 event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  # object
  test 'object method should return the created Format object' do
    assert_kind_of Format, @valid_command.object
  end

end
