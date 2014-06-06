class DeleteAssessmentSectionCommand < Command

  def initialize(assessment_section, doing_user, remote_ip)
    @assessment_section = assessment_section
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      ActiveRecord::Base.transaction do
        @assessment_section.destroy!
        CreateAssessmentSectionCommand.updateSectionIndexes
      end
    rescue ActiveRecord::DeleteRestrictionError => e
      raise e # this should never happen
    rescue => e
      @assessment_section.events << Event.create(
          description: "Attempted to delete assessment section "\
          "\"#{@assessment_section.name},\" but failed: #{e.message}",
          user: @doing_user, address: @remote_ip,
          event_level: EventLevel::ERROR)
      raise "Failed to delete assessment section "\
      "\"#{@assessment_section.name}\": #{e.message}"
    else
      Event.create(description: "Deleted assessment section "\
      "\"#{@assessment_section.name}\" in "\
      "#{@assessment_section.assessment.name}",
                   user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @assessment_section
  end

end
