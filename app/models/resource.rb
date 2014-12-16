class Resource < ActiveRecord::Base

  include Assessable

  has_many :assessment_question_responses, inverse_of: :resource,
           dependent: :destroy
  has_many :children, class_name: 'Resource', foreign_key: 'parent_id',
           inverse_of: :parent, dependent: :destroy
  has_many :creators, inverse_of: :resource, dependent: :destroy
  has_many :extents, inverse_of: :resource, dependent: :destroy
  has_many :resource_dates, inverse_of: :resource, dependent: :destroy
  has_many :resource_notes, inverse_of: :resource, dependent: :destroy
  has_many :subjects, inverse_of: :resource, dependent: :destroy
  has_and_belongs_to_many :events
  belongs_to :format, inverse_of: :resources
  belongs_to :format_ink_media_type, inverse_of: :resources
  belongs_to :format_support_type, inverse_of: :resources
  belongs_to :language, inverse_of: :resources
  belongs_to :location, inverse_of: :resources
  belongs_to :parent, class_name: 'Resource', inverse_of: :children
  belongs_to :user, inverse_of: :resources

  accepts_nested_attributes_for :assessment_question_responses
  accepts_nested_attributes_for :creators, allow_destroy: true
  accepts_nested_attributes_for :extents, allow_destroy: true
  accepts_nested_attributes_for :resource_dates, allow_destroy: true
  accepts_nested_attributes_for :resource_notes, allow_destroy: true
  accepts_nested_attributes_for :subjects, allow_destroy: true

  validates :assessment_percent_complete, allow_blank: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :assessment_score, allow_blank: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :location, presence: true
  validates :name, presence: true, length: { maximum: 255 }
  validates :resource_type, presence: true,
            inclusion: { in: ResourceType.all,
                         message: 'must be a valid resource type.' }
  validates :significance, allow_blank: true,
            inclusion: { in: ResourceSignificance.all,
                         message: 'must be a valid resource significance.' }
  validates :user, presence: true

  validate :validates_not_child_of_item
  validate :validates_one_response_per_question
  validate :validates_same_institution_as_user

  before_validation :prune_empty_submodels
  before_save :update_assessment_percent_complete, :update_assessment_score

  def self.from_ead(ead, user_id)
    doc = REXML::Document.new(ead)

    begin
      User.find(user_id)
    rescue ActiveRecord::RecordNotFound
      raise 'Invalid user ID'
    end

    attrs = {}

    doc.elements.each('//archdesc/did/abstract[1]') do |element|
      attrs[:description] = element.text.strip
    end

    doc.elements.each('//archdesc/did/unitid[1]') do |element|
      attrs[:local_identifier] = element.text.strip
    end

    doc.elements.each('//archdesc/did/unittitle[1]') do |element|
      attrs[:name] = element.text.strip
    end

    doc.elements.each('//archdesc') do |type|
      case type.attribute('level').value.strip
        when 'collection'
          attrs[:resource_type] = ResourceType::COLLECTION
        when 'item'
          attrs[:resource_type] = ResourceType::ITEM
      end
    end

    attrs[:user_id] = user_id

    # creators
    attrs[:creators_attributes] = []
    doc.elements.each('//archdesc/did/origination') do |element|
      if element.attribute('label').value == 'creator'
        attrs[:creators_attributes] << {
            name: element.elements['persname'].text.strip }
      end
    end

    # extents
    attrs[:extents_attributes] = []
    doc.elements.each('//archdesc/did/physdesc/extent') do |extent|
      attrs[:extents_attributes] << { name: extent.text.strip }
    end

    # dates
    attrs[:resource_dates_attributes] = []
    doc.elements.each('//archdesc/did/unitdate') do |element|
      date_struct = {}

      case element.attribute('type').value
        when 'inclusive'
          date_struct[:date_type] = DateType::INCLUSIVE
        when 'bulk'
          date_struct[:date_type] = DateType::BULK
        when 'span'
          date_struct[:date_type] = DateType::SPAN
        when 'single'
          date_struct[:date_type] = DateType::SINGLE
      end

      date_text = element.attribute('normal').value
      date_parts = date_text.split('/')

      case date_struct[:date_type]
        when DateType::SINGLE
          date_struct.merge!(ead_date_to_ymd_hash(date_parts[0]))
        else
          if date_parts.length > 1
            begin_parts = ead_date_to_ymd_hash(date_parts[0])
            end_parts = ead_date_to_ymd_hash(date_parts[1])
            date_struct[:begin_year] = begin_parts[:year] if begin_parts[:year]
            date_struct[:begin_month] = begin_parts[:month] if begin_parts[:month]
            date_struct[:begin_day] = begin_parts[:day] if begin_parts[:day]
            date_struct[:end_year] = end_parts[:year] if end_parts[:year]
            date_struct[:end_month] = end_parts[:month] if end_parts[:month]
            date_struct[:end_day] = end_parts[:day] if end_parts[:day]
          else
            parts = ead_date_to_ymd_hash(date_parts[0])
            date_struct[:begin_year] = parts[:year] if parts[:year]
            date_struct[:begin_month] = parts[:month] if parts[:month]
            date_struct[:begin_day] = parts[:day] if parts[:day]
            date_struct[:end_year] = parts[:year] if parts[:year]
            date_struct[:end_month] = parts[:month] if parts[:month]
            date_struct[:end_day] = parts[:day] if parts[:day]
          end
      end

      attrs[:resource_dates_attributes] << date_struct
    end

    # subjects
    attrs[:subjects_attributes] = []
    doc.elements.each('//archdesc/controlaccess/*') do |subject|
      attrs[:subjects_attributes] << { name: subject.text.strip }
    end

    Resource.new(attrs)
  end

  ##
  # @return Array of all assessed items in a collection, regardless of depth
  # in the hierarchy.
  #
  def all_assessed_items
    all_children.select{ |x| x.resource_type == ResourceType::ITEM and
        x.assessment_percent_complete >= 0.999999 }
  end

  ##
  # @return Array of all children of a resource, regardless of depth in the
  # hierarchy.
  #
  def all_children
    def accumulate_children(resource, resource_bucket)
      resource.children.each do |child|
        resource_bucket << child
        accumulate_children(child, resource_bucket)
      end
    end

    resources = []
    accumulate_children(self, resources)
    resources
  end

  def as_csv
    questions = []
    responses = []
    self.assessment_question_responses.each_with_index do |response, index|
      questions << "Q#{index + 1}: #{response.assessment_question.name}"
      responses << response.assessment_question_option.name
    end

    require 'csv'
    # CSV format is defined in G:|AcqCatPres\PSAP\Design\CSV
    CSV.generate do |csv|
      csv << ['Local Identifier'] +
          ['Title/Name'] +
          ['PSAP Assessment Score'] +
          ['Resource Type'] +
          ['Parent Resource'] +
          ['Format'] +
          ['Significance'] +
          (['Creator'] * self.creators.length) +
          (['Date'] * self.resource_dates.length) +
          ['Language'] +
          (['Subject'] * self.subjects.length) +
          (['Extent'] * self.extents.length) +
          ['Rights'] +
          ['Description'] +
          (['Note'] * self.resource_notes.length) +
          ['Created'] +
          ['Updated'] +
          questions
      csv << [self.local_identifier] +
          [self.name] +
          [self.total_assessment_score * 100] +
          [self.readable_resource_type] +
          [self.parent ? self.parent.name : nil] +
          [self.format ? self.format.name : nil] +
          [self.readable_significance] +
          self.creators.map { |r| r.name } +
          self.resource_dates.map { |r| r.as_dublin_core_string } +
          [self.language ? self.language.english_name : nil] +
          self.subjects.map { |s| s.name } +
          self.extents.map { |e| e.name } +
          [self.rights] +
          [self.description] +
          self.resource_notes.map { |n| n.value } +
          [self.created_at.iso8601] +
          [self.updated_at.iso8601] +
          responses
    end
  end

  ##
  # Returns a hash containing statistics of all assessed items in the
  # collection.
  #
  # @return hash with mean, median, low, and high keys
  #
  def assessed_item_statistics
    stats = { mean: 0, median: 0, low: nil, high: 0 }
    all_items = all_assessed_items
    if all_items.length < 1
      return nil
    end

    all_items.each do |item|
      stats[:high] = item.total_assessment_score if item.total_assessment_score > stats[:high]
      stats[:low] = item.total_assessment_score if
          stats[:low].nil? or item.total_assessment_score < stats[:low]
    end
    stats[:mean] = all_items.map{ |r| r.total_assessment_score }.sum.to_f / all_items.length.to_f
    sorted = all_items.map{ |r| r.total_assessment_score }.sort
    len = sorted.length
    stats[:median] = (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
    stats
  end

  ##
  # @return float
  #
  def assessment_percent_complete_in_section(section)
    all_aqs = section.assessment_questions_for_format(self.format)
    if all_aqs.length > 0
      complete_aqs = self.complete_assessment_questions_in_section(section)
      return complete_aqs.length.to_f / all_aqs.length.to_f
    end
    0.0
  end

  def filename
    self.local_identifier ? self.local_identifier : self.id.to_s
  end

  ##
  # Submitted assessment forms will often have empty submodels such as creator,
  # extent, etc. This method will remove them.
  #
  def prune_empty_submodels
    self.creators = self.creators.select{ |c| c.name.length > 0 }
    self.extents = self.extents.select{ |e| e.name.length > 0 }
    self.resource_dates = self.resource_dates.select{ |r| r.year }
    self.resource_notes = self.resource_notes.select{ |r| r.value.length > 0 }
    self.subjects = self.subjects.select{ |s| s.name.length > 0 }
  end

  def readable_resource_type
    case resource_type
      when ResourceType::COLLECTION
        'Collection'
      when ResourceType::ITEM
        'Item'
    end
  end

  def readable_significance
    case significance
      when ResourceSignificance::LOW
        'Low'
      when ResourceSignificance::MODERATE
        'Moderate'
      when ResourceSignificance::HIGH
        'High'
    end
  end

  ##
  # Returns the assessment score of the resource, factoring in
  # institution/location scores as well, unlike assessment_score which does not.
  #
  def total_assessment_score
    self.update_assessment_score
    self.assessment_score * 0.9 + self.location.assessment_score * 0.1
  end

  def update_assessment_percent_complete
    self.assessment_percent_complete =
        (self.format and self.format.all_assessment_questions.any?) ?
            self.assessment_question_responses.length.to_f /
            self.format.all_assessment_questions.length.to_f : 0
  end

  ##
  # Updates the score of the resource only, without taking location/institution
  # into account.
  #
  # Scores are stored (rather than being calculated on-the-fly) in order to
  # make for simpler queries.
  #
  # Overrides Assessable mixin
  #
  def update_assessment_score
    # https://github.com/PresConsUIUC/PSAP/wiki/Scoring
    if self.format
      question_score = 0
      self.assessment_question_responses.each do |response|
        question_score += response.assessment_question_option.value *
            response.assessment_question.weight
      end

      if self.format.format_class == FormatClass::BOUND_PAPER or
          self.format.fid == 159 # Unbound Paper -> Original Document
        if self.format_support_type and self.format_ink_media_type
          format_score = self.format_support_type.score * 0.6 +
              self.format_ink_media_type.score * 0.4
        else
          format_score = 0
        end
      else
        format_score = self.format.score * 0.45
      end

      self.assessment_score = format_score + (question_score / 100) * 0.55
    else
      self.assessment_score = 0
    end
  end

  private

  def self.ead_date_to_ymd_hash(date)
    date = date.split('-')
    parts = {}
    parts[:day] = date[2].to_i if date.length > 2
    parts[:month] = date[1].to_i if date.length > 1
    parts[:year] = date[0].to_i
    parts
  end

  def validates_not_child_of_item
    if parent and parent.resource_type != ResourceType::COLLECTION
      errors[:base] << 'Only collection resources can have sub-resources.'
    end
  end

  def validates_one_response_per_question
    if self.assessment_question_responses.uniq{ |r| r.assessment_question.qid }.length <
        self.assessment_question_responses.length
      # TODO: fix
      #errors[:base] << 'Only one response allowed per assessment question.'
    end
  end

  def validates_same_institution_as_user
    if user and !user.is_admin? and
        user.institution != self.location.repository.institution
      errors[:base] << 'Owning user must be of the same institution.'
    end
  end

end
