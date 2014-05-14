class CreateLocationCommand < Command

  def initialize(repository, location_params, doing_user, remote_ip)
    @repository = repository
    @location_params = location_params
    @doing_user = doing_user
    @location = @repository.locations.build(@location_params)
    @remote_ip = remote_ip
  end

  def execute
    begin
      # Fail if a non-admin user is trying to create the location in a
      # different institution
      if !@doing_user.is_admin? &&
          @doing_user.institution != @repository.institution
        raise 'Insufficient privileges'
      end

      @location.save!
    rescue ActiveRecord::RecordInvalid => e
      Event.create(description: "Attempted to create location, but failed: "\
      "#{@location.errors.full_messages[0]}",
                   user: @doing_user, address: @remote_ip,
                   event_level: EventLevel::DEBUG)
      raise "Failed to create location: #{@location.errors.full_messages[0]}"
    rescue => e
      Event.create(description: "Attempted to create location, but failed: "\
      "#{e.message}",
                   user: @doing_user, address: @remote_ip,
                   event_level: EventLevel::ERROR)
      raise "Failed to create location: #{e.message}"
    else
      Event.create(description: "Created location \"#{@location.name}\" in "\
      "repository \"#{@repository.name}\"",
                   user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @location
  end

end
