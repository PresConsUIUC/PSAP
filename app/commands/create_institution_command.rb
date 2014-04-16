class CreateInstitutionCommand < Command

  def initialize(institution_params, user, remote_ip)
    @institution_params = institution_params
    @user = user
    @institution = Institution.new(@institution_params)
    @remote_ip = remote_ip
  end

  def execute
    @institution.users << @user
    @institution.save!
    Event.create(description: "Created institution \"#{@institution.name}\"",
                 user: @user, address: @remote_ip)
  end

  def object
    @institution
  end

end
