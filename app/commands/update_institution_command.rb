class UpdateInstitutionCommand < Command

  def initialize(institution, institution_params, user, remote_ip)
    @institution = institution
    @institution_params = institution_params
    @user = user
    @remote_ip = remote_ip
  end

  def execute
    @institution.update!(@institution_params)
    Event.create(description: "Updated institution \"#{@institution.name}\"",
                 user: @user, address: @remote_ip,
                 event_status: EventStatus::SUCCESS)
  end

  def object
    @institution
  end

end
