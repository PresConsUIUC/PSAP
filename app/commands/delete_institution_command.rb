class DeleteInstitutionCommand < Command

  def initialize(institution, user)
    @institution = institution
    @user = user
  end

  def execute
    begin
      @institution.destroy!
      Event.create(description: "Deleted institution \"#{@institution.name}\"",
                   user: @user)
    rescue ActiveRecord::DeleteRestrictionError => e
      @institution.errors.add(:base, e)
      raise e
    end
  end

  def object
    @institution
  end

end
