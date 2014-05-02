class CreateFormatCommand < Command

  def initialize(format_params, user, remote_ip)
    @format_params = format_params
    @user = user
    @remote_ip = remote_ip
    @format = Format.new(format_params)
  end

  def execute
    begin
      @format.save!
    rescue ActiveRecord::RecordInvalid => e
      Event.create(description: "Failed to create format: #{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE)
      raise e
    rescue => e
      Event.create(description: "Failed to create format: #{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE)
      raise e
    else
      Event.create(description: "Created format \"#{@format.name}\"",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::SUCCESS)
    end
  end

  def object
    @format
  end

end
