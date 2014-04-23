class CreateAssessmentSectionCommand < Command

  def self.updateSectionIndexes(assessment_section = nil)
    if assessment_section
      sections = AssessmentSection.where.not(id: assessment_section.id).
          where('"index" >= ?', assessment_section.index).order(:index)
      sections.each do |section|
        section.index = section.index + 1
        section.save!
      end
    else
      sections = AssessmentSection.order(:index)
      for i in 0..sections.length
        sections[i].index = i
        sections[i].save!
      end
    end
  end

  def initialize(assessment_section_params, user, remote_ip)
    @assessment_section_params = assessment_section_params
    @user = user
    @assessment_section = AssessmentSection.new(@assessment_section_params)
    @remote_ip = remote_ip
  end

  def execute
    if @assessment_section.index.blank?
      @assessment_section.index = 0
    else
      @assessment_section.index += 1
    end

    @assessment_section.save!

    CreateAssessmentSectionCommand.updateSectionIndexes(@assessment_section)

    Event.create(description: "Created assessment section "\
    "\"#{@assessment_section.name}\"",
                 user: @user, address: @remote_ip)
  end

  def object
    @assessment_section
  end

end
