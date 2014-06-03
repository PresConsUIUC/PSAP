class UpdateAssessmentSectionCommand < Command

  def initialize(assessment_section, assessment_section_params, doing_user,
      remote_ip)
    @assessment_section = assessment_section
    @assessment_section_params = assessment_section_params
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    @assessment_section_params['index'] = @assessment_section_params['index'] ?
        @assessment_section_params['index'].to_i + 1 : 0

    begin
      ActiveRecord::Base.transaction do
        @assessment_section.update!(@assessment_section_params)
        if @assessment_section.index != @assessment_section_params['index']
          CreateAssessmentSectionCommand.updateSectionIndexes(@assessment_section)
        end
      end
    rescue ActiveRecord::RecordInvalid
      Event.create(description: "Attempted to update assessment section "\
      "\"#{@assessment_section.name},\" but failed: "\
      "#{@assessment_section.errors.full_messages[0]}",
                   user: @doing_user, address: @remote_ip,
                   event_level: EventLevel::DEBUG)
      raise ValidationError,
            "Failed to update assessment section "\
            "\"#{@assessment_section.name}\": "\
            "#{@assessment_section.errors.full_messages[0]}"
    rescue => e
      Event.create(description: "Attempted to update assessment section "\
      "\"#{@assessment_section.name},\" but failed: #{e.message}",
                   user: @doing_user, address: @remote_ip,
                   event_level: EventLevel::ERROR)
      raise "Failed to update assessment section "\
      "\"#{@assessment_section.name}\": #{e.message}"
    else
      Event.create(description: "Updated assessment section "\
      "\"#{@assessment_section.name}\" in #{@assessment_section.assessment.name}",
                   user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @assessment_section
  end

end
