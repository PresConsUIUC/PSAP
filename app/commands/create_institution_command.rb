class CreateInstitutionCommand < Command

  def initialize(institution_params, user)
    @institution_params = institution_params
    @user = user
  end

  def execute
    @institution = Institution.new(@institution_params)
    @institution.users << user
    @institution.save

    Event.create(description: "Created institution \"#{@institution.name}\"",
                 user: @user)
  end

  def object
    @institution
  end

end
