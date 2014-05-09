class DeleteInstitutionCommand < Command

  def initialize(institution, doing_user, remote_ip)
    @institution = institution
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @institution.destroy!
    rescue ActiveRecord::DeleteRestrictionError => e
      Event.create(description: "Attempted to delete institution "\
      "\"#{@institution.name},\" but failed as there are one or more users "\
      "affiliated with it.",
                   user: @doing_user, address: @remote_ip,
                   event_level: EventLevel::DEBUG)
      raise "The institution \"#{@institution.name}\" "\
      "cannot be deleted, as there are one or more users affiliated with it."
    rescue => e
      Event.create(description: "Attempted to delete institution "\
      "\"#{@institution.name},\" but failed: "\
      "#{@institution.errors.full_messages[0]}",
                   user: @doing_user, address: @remote_ip,
                   event_level: EventLevel::ERROR)
      raise "Failed to delete institution: "\
      "#{@institution.errors.full_messages[0]}"
    else
      Event.create(description: "Deleted institution \"#{@institution.name}\"",
                   user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @institution
  end

end
