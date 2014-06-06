class CreateAssessmentSectionCommand < Command

  def self.updateSectionIndexes(assessment_section = nil)
    if assessment_section
      sections = AssessmentSection.where.not(id: assessment_section.id).
          where('"index" >= ?', assessment_section.index).order(:index)
      ActiveRecord::Base.transaction do
        sections.each do |section|
          section.index = section.index + 1
          section.save!
        end
      end
    else
      sections = AssessmentSection.order(:index)
      ActiveRecord::Base.transaction do
        sections.each_with_index do |section, i|
          section.index = i
          section.save!
        end
      end
    end
  end

  def initialize(assessment_section_params, doing_user, remote_ip)
    @assessment_section_params = assessment_section_params
    @doing_user = doing_user
    @assessment_section = AssessmentSection.new(@assessment_section_params)
    @remote_ip = remote_ip
  end

  def execute
    if @assessment_section.index.blank?
      @assessment_section.index = 0
    else
      @assessment_section.index += 1
    end

    begin
      ActiveRecord::Base.transaction do
        @assessment_section.save!
        CreateAssessmentSectionCommand.updateSectionIndexes(@assessment_section)
      end
    rescue ActiveRecord::RecordInvalid
      @assessment_section.events << Event.create(
          description: "Attempted to create assessment section, but "\
          "failed: #{@assessment_section.errors.full_messages[0]}",
          user: @doing_user, address: @remote_ip,
          event_level: EventLevel::DEBUG)
      raise ValidationError, "Failed to create assessment section: "\
      "#{@assessment_section.errors.full_messages[0]}"
    rescue => e
      @assessment_section.events << Event.create(
          description: "Attempted to create assessment section, but "\
          "failed: #{e.message}",
          user: @doing_user, address: @remote_ip,
          event_level: EventLevel::ERROR)
      raise "Failed to create assessment section: #{e.message}"
    else
      @assessment_section.events << Event.create(
          description: "Created assessment section "\
          "\"#{@assessment_section.name}\" in #{@assessment_section.assessment.name}",
          user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @assessment_section
  end

end
