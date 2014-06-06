class DeleteFormatCommand < Command

  def initialize(format, doing_user, remote_ip)
    @format = format
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @format.destroy!
    rescue ActiveRecord::DeleteRestrictionError => e
      @format.events << Event.create(
          description: "Attempted to delete format \"#{@format.name},\" but "\
          "failed as it is being used by one or more resource assessments.",
          user: @doing_user, address: @remote_ip,
          event_level: EventLevel::DEBUG)
      raise "The format \"#{@format.name}\" cannot be deleted, as it is "\
      "being used by one or more resource assessments."
    rescue => e
      Event.create(description: "Attempted to delete format "\
      "\"#{@format.name},\" but failed: #{e.message}",
                   user: @doing_user, address: @remote_ip,
                   event_level: EventLevel::ERROR)
      raise "Failed to delete format: #{e.message}"
    else
      Event.create(description: "Deleted format \"#{@format.name}\"",
                   user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @format
  end

end
