class DeleteInstitutionCommand < Command

  def initialize(institution, doing_user, remote_ip)
    @institution = institution
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @institution.destroy!
    rescue ActiveRecord::DeleteRestrictionError => e
      raise "The institution \"#{@institution.name}\" "\
      "cannot be deleted, as there are one or more users affiliated with it."
    rescue => e
      raise "Failed to delete institution: #{e.message}"
    end
  end

  def object
    @institution
  end

end
