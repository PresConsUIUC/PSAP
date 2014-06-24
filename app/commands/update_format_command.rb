class UpdateFormatCommand < Command

  def initialize(format, format_params, doing_user, remote_ip)
    @format = format
    @format_params = format_params
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      original_name = @format.name
      @format.update!(@format_params)
    rescue ActiveRecord::RecordInvalid
      @format.events << Event.create(
          description: "Attempted to update format \"#{original_name},\" but "\
          "failed: #{@format.errors.full_messages[0]}",
          user: @doing_user, address: @remote_ip,
          event_level: EventLevel::DEBUG)
      raise ValidationError,
            "Failed to update format \"#{original_name}\": "\
            "#{@format.errors.full_messages[0]}"
    rescue => e
      @format.events << Event.create(
          description: "Attempted to update format "\
          "\"#{original_name},\" but failed: #{e.message}",
          user: @doing_user, address: @remote_ip,
          event_level: EventLevel::ERROR)
      raise "Failed to update format \"#{original_name}\": #{e.message}"
    else
      @format.events << Event.create(
          description: "Updated format \"#{@format.name}\"",
          user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @format
  end

end
