class CreateInstitutionCommand < Command

  def initialize(institution_params, user, remote_ip)
    @institution_params = institution_params
    @user = user
    @institution = Institution.new(@institution_params)
    @remote_ip = remote_ip
  end

  def execute
    begin
      @institution.users << @user
      @institution.save!
    rescue ActiveRecord::RecordInvalid => e
      Event.create(description: "Failed to create institution: #{e.message}",
                   user: @user, address: @remote_ip,
                   event_level: EventLevel::DEBUG)
      raise e
    rescue => e
      Event.create(description: "Failed to create institution: #{e.message}",
                   user: @user, address: @remote_ip,
                   event_level: EventLevel::ERROR)
      raise e
    else
      Event.create(description: "Created institution \"#{@institution.name}\"",
                   user: @user, address: @remote_ip)
    end
  end

  def object
    @institution
  end

end
