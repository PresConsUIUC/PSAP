class DeleteInstitutionCommand < Command

  def initialize(institution, user, remote_ip)
    @institution = institution
    @user = user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @institution.destroy!
    rescue ActiveRecord::DeleteRestrictionError => e
      Event.create(description: "Failed to delete institution: #{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE)
      raise e
    rescue => e
      Event.create(description: "Failed to delete institution: #{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE)
      raise e
    else
      Event.create(description: "Deleted institution \"#{@institution.name}\"",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::SUCCESS)
    end
  end

  def object
    @institution
  end

end
