module Assessable

  extend ActiveSupport::Concern

  included do
    validates :assessment_score, allow_blank: true,
              numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }

    before_save :update_assessment_complete
    before_save :update_assessment_score
  end

  ##
  # @return Hash of AssessmentQuestionResponses keyed by section id
  #
  def assessment_question_responses_by_section
    sections = {}
    self.assessment_question_responses.each do |response|
      section_id = response.assessment_question.assessment_section.id
      sections[section_id] = [] unless sections[section_id]
      sections[section_id] << response
    end
    sections
  end

  ##
  # @return Hash of floats keyed by section id
  #
  def assessment_section_scores
    sections = {}
    assessment_question_responses_by_section.each do |section_id, responses|
      sections[section_id] = 0 unless sections[section_id]
      responses.each do |response|
        sections[section_id] += response.assessment_question_option.value *
            response.assessment_question.weight
      end
      section = AssessmentSection.find(section_id)
      sections[section_id] = (sections[section_id] / section.max_score)
    end
    sections
  end

  def complete_assessment_questions_in_section(assessment_section)
    self.assessment_question_responses.
        select{ |r| !r.assessment_question_option.nil? }.
        map(&:assessment_question).
        select{ |q| q.assessment_section.id == assessment_section.id }
  end

  ##
  # @return AssessmentQuestionResponse or nil
  #
  def response_to_question(assessment_question)
    self.assessment_question_responses.
        where(assessment_question_id: assessment_question.id).first
  end

  def update_assessment_complete
    self.assessment_complete = self.assessment_question_responses.length > 0
    nil
  end

  ##
  # Generally called before_save
  #
  def update_assessment_score
    # https://github.com/PresConsUIUC/PSAP/wiki/Scoring
    self.assessment_score = 0.0
    self.assessment_question_responses.each do |response|
      self.assessment_score += response.assessment_question_option.value *
          response.assessment_question.weight
    end
    self.assessment_score *= 0.01
  end

end
