class UpdateInstitutionCommand < Command

  def initialize(institution, institution_params, doing_user, remote_ip)
    @institution = institution
    @institution_params = institution_params
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @institution.update!(@institution_params)
    rescue ActiveRecord::RecordInvalid
      Event.create(description: "Attempted to update institution "\
      "\"#{@institution.name},\" but failed: "\
      "#{@institution.errors.full_messages[0]}",
                   user: @doing_user, address: @remote_ip,
                   event_level: EventLevel::DEBUG)
      raise ValidationError,
            "Failed to update institution \"#{@institution.name}\": "\
            "#{@institution.errors.full_messages[0]}"
    rescue => e
      Event.create(description: "Attempted to update institution "\
      "\"#{@institution.name},\" but failed: #{e.message}",
                   user: @doing_user, address: @remote_ip,
                   event_level: EventLevel::ERROR)
      raise "Failed to update institution \"#{@institution.name}\": #{e.message}"
    else
      Event.create(description: "Updated institution \"#{@institution.name}\"",
                   user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @institution
  end

end
