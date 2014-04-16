class DeleteInstitutionCommand < Command

  def initialize(institution, user, remote_ip)
    @institution = institution
    @user = user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @institution.destroy!
      Event.create(description: "Deleted institution \"#{@institution.name}\"",
                   user: @user, address: @remote_ip)
    rescue ActiveRecord::DeleteRestrictionError => e
      @institution.errors.add(:base, e)
      raise e
    end
  end

  def object
    @institution
  end

end
