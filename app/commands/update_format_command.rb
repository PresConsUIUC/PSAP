class UpdateFormatCommand < Command

  def initialize(format, format_params, user, remote_ip)
    @format = format
    @format_params = format_params
    @user = user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @format.update!(@format_params)
    rescue => e
      Event.create(description: "Failed to update format "\
      "\"#{@format.name}\": #{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE)
      raise e
    else
      Event.create(description: "Updated format \"#{@format.name}\"",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::SUCCESS)
    end
  end

  def object
    @format
  end

end
