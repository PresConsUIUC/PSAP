class UpdateAssessmentSectionCommand < Command

  def initialize(assessment_section, assessment_section_params, user,
      remote_ip)
    @assessment_section = assessment_section
    @assessment_section_params = assessment_section_params
    @user = user
    @remote_ip = remote_ip
  end

  def execute
    if @assessment_section_params[:index].length == 0
      @assessment_section_params[:index] = '0'
    else
      @assessment_section_params[:index] =
          @assessment_section_params[:index].to_i + 1
    end

    begin
      @assessment_section.update!(@assessment_section_params)

      if @assessment_section.index != @assessment_section_params[:index]
        CreateAssessmentSectionCommand.updateSectionIndexes(@assessment_section)
      end
    rescue ActiveRecord::RecordInvalid => e
      Event.create(description: "Failed to update assessment section "\
      "\"#{@assessment_section.name}\": #{e.message}",
                   user: @user, address: @remote_ip,
                   event_level: EventLevel::DEBUG)
      raise e
    rescue => e
      Event.create(description: "Failed to update assessment section "\
      "\"#{@assessment_section.name}\": #{e.message}",
                   user: @user, address: @remote_ip,
                   event_level: EventLevel::ERROR)
      raise e
    else
      Event.create(description: "Updated assessment section "\
      "\"#{@assessment_section.name}\" in #{@assessment_section.assessment.name}",
                   user: @user, address: @remote_ip)
    end
  end

  def object
    @assessment_section
  end

end
