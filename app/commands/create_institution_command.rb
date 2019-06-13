class CreateInstitutionCommand < Command

  def initialize(institution_params, doing_user, remote_ip)
    @doing_user = doing_user
    @remote_ip = remote_ip
    @institution = Institution.new(institution_params)
  end

  def execute
    begin
      @institution.save!
    rescue ActiveRecord::RecordInvalid
      raise ValidationError, "Failed to create institution: "\
      "#{@institution.errors.full_messages[0]}"
    rescue => e
      raise "Failed to create institution: #{e.message}"
    end
  end

  def object
    @institution
  end

end
