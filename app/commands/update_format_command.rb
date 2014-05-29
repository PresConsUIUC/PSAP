class UpdateFormatCommand < Command

  def initialize(format, format_params, doing_user, remote_ip)
    @format = format
    @format_params = format_params
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @format.update!(@format_params)
    rescue ActiveRecord::RecordInvalid # TODO: messages use new name (which may be changed/invalid)
      Event.create(description: "Attempted to update format "\
      "\"#{@format.name},\" but failed: #{@format.errors.full_messages[0]}",
                   user: @doing_user, address: @remote_ip,
                   event_level: EventLevel::DEBUG)
      raise ValidationError,
            "Failed to update format \"#{@format.name}\": "\
            "#{@format.errors.full_messages[0]}"
    rescue => e
      Event.create(description: "Attempted to update format "\
      "\"#{@format.name},\" but failed: #{e.message}",
                   user: @doing_user, address: @remote_ip,
                   event_level: EventLevel::ERROR)
      raise "Failed to update format \"#{@format.name}\": #{e.message}"
    else
      Event.create(description: "Updated format \"#{@format.name}\"",
                   user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @format
  end

end
