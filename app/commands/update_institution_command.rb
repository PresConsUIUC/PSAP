class UpdateInstitutionCommand < Command

  def initialize(institution, institution_params, user, remote_ip)
    @institution = institution
    @institution_params = institution_params
    @user = user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @institution.update!(@institution_params)
    rescue ActiveRecord::RecordInvalid => e
      Event.create(description: "Failed to update institution "\
      "\"#{@institution.name}\": #{e.message}",
                   user: @user, address: @remote_ip,
                   event_level: EventLevel::DEBUG)
      raise e
    rescue => e
      Event.create(description: "Failed to update institution "\
      "\"#{@institution.name}\": #{e.message}",
                   user: @user, address: @remote_ip,
                   event_level: EventLevel::ERROR)
      raise e
    else
      Event.create(description: "Updated institution \"#{@institution.name}\"",
                   user: @user, address: @remote_ip)
    end
  end

  def object
    @institution
  end

end
