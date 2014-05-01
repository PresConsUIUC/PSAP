class DeleteAssessmentSectionCommand < Command

  def initialize(assessment_section, user, remote_ip)
    @assessment_section = assessment_section
    @user = user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @assessment_section.destroy!

      CreateAssessmentSectionCommand.updateSectionIndexes

      Event.create(description: "Deleted assessment section "\
      "\"#{@assessment_section.name}\" in #{@assessment_section.assessment.name}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::SUCCESS)
    rescue ActiveRecord::DeleteRestrictionError => e
      @assessment_section.errors.add(:base, e)
      raise e
    end
  end

  def object
    @assessment_section
  end

end
