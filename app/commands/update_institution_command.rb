class UpdateInstitutionCommand < Command

  def initialize(institution, institution_params, user)
    @institution = institution
    @institution_params = institution_params
    @user = user
  end

  def execute
    @institution.update!(@institution_params)
    Event.create(description: "Updated institution \"#{@institution.name}\"",
                 user: @user)
  end

  def object
    @institution
  end

end
