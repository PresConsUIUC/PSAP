require 'test_helper'

class UpdateFormatCommandTest < ActiveSupport::TestCase

  def setup
    @format = formats(:format_one)
    @valid_params = formats(:format_one).attributes
    @valid_params.delete('id')
    @valid_params['name'] = 'asdfjkjhasfd'
    @user = users(:normal_user)
    @remote_ip = '10.0.0.1'
    @valid_command = UpdateFormatCommand.new(@format, @valid_params, @user,
                                             @remote_ip)

    @invalid_params = @valid_params.dup
    @invalid_params['score'] = -1
    @invalid_command = UpdateFormatCommand.new(@format, @invalid_params, @user,
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
    assert_equal "Updated format \"#{@valid_command.object.name}\"",
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
    assert_equal "Attempted to update format \"#{@format.name},\" but "\
    "failed: Score must be greater than or equal to 0",
                 event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  # object
  test 'object method should return the Format object' do
    assert_kind_of Format, @valid_command.object
  end

end
