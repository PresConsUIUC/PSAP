class CreateAndJoinInstitutionCommand < Command

  def initialize(institution_params, doing_user, remote_ip)
    @doing_user = doing_user
    @remote_ip = remote_ip
    @institution = Institution.new(institution_params)
  end

  def execute
    begin
      ActiveRecord::Base.transaction do
        @institution.save!
        JoinInstitutionCommand.new(@doing_user, @institution, @doing_user,
                                   @remote_ip).execute if @doing_user
      end
    rescue ActiveRecord::RecordInvalid
      @institution.events << Event.create(
          description: "Attempted to create and join institution, but failed: "\
          "#{@institution.errors.full_messages[0]}",
          user: @doing_user, address: @remote_ip,
          event_level: EventLevel::DEBUG)
      raise ValidationError, "Failed to create and join institution: "\
      "#{@institution.errors.full_messages[0]}"
    rescue => e
      @institution.events << Event.create(
          description: "Attempted to create and join institution, but failed: "\
          "#{e.message}",
          user: @doing_user, address: @remote_ip,
          event_level: EventLevel::ERROR)
      raise "Failed to create and join institution: #{e.message}"
    else
      if @doing_user
        @institution.events << Event.create(
            description: "Created and joined institution \"#{@institution.name}\"",
            user: @doing_user, address: @remote_ip)
      else
        @institution.events << Event.create(
            description: "Created and institution \"#{@institution.name}\"",
            user: @doing_user, address: @remote_ip)
      end
    end
  end

  def object
    @institution
  end

end
