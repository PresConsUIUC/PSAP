class CreateFormatCommand < Command

  def initialize(format_params, doing_user, remote_ip)
    @format_params = format_params
    @doing_user = doing_user
    @remote_ip = remote_ip
    @format = Format.new(format_params)
  end

  def execute
    begin
      @format.save!

      unless @format.temperature_ranges.any?
        TemperatureRange.create!(min_temp_f: nil, max_temp_f: 32, score: 1,
                                 format: @format)
        TemperatureRange.create!(min_temp_f: 33, max_temp_f: 54, score: 0.67,
                                 format: @format)
        TemperatureRange.create!(min_temp_f: 55, max_temp_f: 72, score: 0.33,
                                 format: @format)
        TemperatureRange.create!(min_temp_f: 73, max_temp_f: nil, score: 0,
                                 format: @format)
      end
    rescue ActiveRecord::RecordInvalid
      @format.events << Event.create(
          description: "Attempted to create format, but failed: "\
          "#{@format.errors.full_messages[0]}",
          user: @doing_user, address: @remote_ip,
          event_level: EventLevel::DEBUG)
      raise ValidationError,
            "Failed to create format: #{@format.errors.full_messages[0]}"
    rescue => e
      @format.events << Event.create(
          description: "Attempted to create format, but failed: "\
          "#{e.message}",
          user: @doing_user, address: @remote_ip,
          event_level: EventLevel::ERROR)
      raise "Failed to create format: #{e.message}"
    else
      @format.events << Event.create(
          description: "Created format \"#{@format.name}\"",
          user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @format
  end

end
