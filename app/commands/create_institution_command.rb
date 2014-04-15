class CreateInstitutionCommand < Command

  def initialize(institution_params, user)
    @institution_params = institution_params
    @user = user
    @institution = Institution.new(@institution_params)
  end

  def execute
    @institution.users << user
    @institution.save!
    Event.create(description: "Created institution \"#{@institution.name}\"",
                 user: @user)
  end

  def object
    @institution
  end

end
