class CreateFormatCommand < Command

  def initialize(format_params, user, remote_ip)
    @format_params = format_params
    @doing_user = doing_user
    @remote_ip = remote_ip
    @format = Format.new(format_params)
  end

  def execute
    begin
      @format.save!
    rescue ActiveRecord::RecordInvalid => e
      Event.create(description: "Attempted to create format, but failed: "\
      "#{@format.errors.full_messages[0]}",
                   user: @doing_user, address: @remote_ip,
                   event_level: EventLevel::DEBUG)
      raise "Failed to create format: #{@format.errors.full_messages[0]}"
    rescue => e
      Event.create(description: "Attempted to create format, but failed: "\
      "#{@format.errors.full_messages[0]}",
                   user: @doing_user, address: @remote_ip,
                   event_level: EventLevel::ERROR)
      raise "Failed to create format: #{@format.errors.full_messages[0]}"
    else
      Event.create(description: "Created format \"#{@format.name}\"",
                   user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @format
  end

end
