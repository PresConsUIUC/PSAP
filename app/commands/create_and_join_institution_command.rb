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
        if @doing_user
          if @doing_user.is_admin? # admins can change their institutions with no review
            @doing_user.institution = @institution
            @doing_user.save!
          else # non-admin institution changes require review
            @doing_user.desired_institution = @institution
            @doing_user.save!
            UserMailer.institution_change_review_request_email(@doing_user).deliver
          end
        end
        @institution.reload
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
      @institution.events << Event.create(
          description: "Created and joined institution \"#{@institution.name}\"",
          user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @institution
  end

end
