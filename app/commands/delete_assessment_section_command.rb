class DeleteAssessmentSectionCommand < Command

  def initialize(assessment_section, user, remote_ip)
    @assessment_section = assessment_section
    @user = user
    @remote_ip = remote_ip
  end

  def execute
    begin
      ActiveRecord::Base.transaction do
        @assessment_section.destroy!
        CreateAssessmentSectionCommand.updateSectionIndexes
      end
    rescue ActiveRecord::DeleteRestrictionError => e
      Event.create(description: "Failed to delete assessment section: "\
      "#{e.message}",
                   user: @user, address: @remote_ip,
                   event_level: EventLevel::DEBUG)
      raise e
    rescue => e
      Event.create(description: "Failed to delete assessment section: "\
      "#{e.message}",
                   user: @user, address: @remote_ip,
                   event_level: EventLevel::ERROR)
      raise e
    else
      Event.create(description: "Deleted assessment section "\
      "\"#{@assessment_section.name}\" in #{@assessment_section.assessment.name}",
                   user: @user, address: @remote_ip)
    end
  end

  def object
    @assessment_section
  end

end
