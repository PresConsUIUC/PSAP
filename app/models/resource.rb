class Resource < ActiveRecord::Base

  include Assessable

  has_many :assessment_question_responses, inverse_of: :resource,
           dependent: :destroy
  has_many :children, -> { order(:name) }, class_name: 'Resource',
           foreign_key: 'parent_id', inverse_of: :parent, dependent: :destroy
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

  validates :assessment_type, allow_blank: true,
            inclusion: { in: AssessmentType.all,
                         message: 'must be a valid assessment type.' }
  validates :location, presence: true
  validates :name, presence: true, length: { maximum: 255 }
  validates :resource_type, presence: true,
            inclusion: { in: ResourceType.all,
                         message: 'must be a valid resource type.' }
  validates :significance, allow_blank: true,
            inclusion: { in: ResourceSignificance.all,
                         message: 'must be a valid resource significance.' }
  validates :user, presence: true

  validate :validates_collections_not_assessable
  validate :validates_not_child_of_item
  validate :validates_same_institution_as_user

  before_validation :prune_empty_submodels
  before_save :update_assessment_complete

  def self.all_matching_query(params, starting_set = nil)
    starting_set = Resource.all unless starting_set
    resources = starting_set

    # assessed
    if params[:assessed] == '1'
      resources = resources.where(assessment_complete: true)
    elsif params[:assessed] == '0'
      resources = resources.where(assessment_complete: false)
    end
    # format_id
    resources = resources.where(format_id: params[:format_id]) unless
        params[:format_id].blank?
    # language_id
    resources = resources.where(language_id: params[:language_id]) unless
        params[:language_id].blank?
    # repository_id
    resources = resources.
        where('locations.repository_id = ?', params[:repository_id]) unless
        params[:repository_id].blank?
    # q
    unless params[:q].blank?
      q = "%#{params[:q].strip.downcase}%"
      resources = resources.joins(:resource_notes, :subjects).
          where('LOWER(resources.description) LIKE ? '\
          'OR LOWER(resources.local_identifier) LIKE ? '\
          'OR LOWER(resources.name) LIKE ? '\
          'OR LOWER(resources.rights) LIKE ? '\
          'OR LOWER(resource_notes.value) LIKE ? '\
          'OR LOWER(subjects.name) LIKE ?',
                q, q, q, q, q, q)
    end
    # resource_type
    resources = resources.where(resource_type: params[:resource_type]) unless
        params[:resource_type].blank? or params[:resource_type] == 'any'
    # score/score_direction
    if !params[:score].blank? and !params[:score_direction].blank?
      score = params[:score].to_f / 100
      direction = params[:score_direction] == 'greater' ? '>' : '<'
      resources = resources.
          where("resources.assessment_score #{direction} #{score}")
    end
    # user_id
    resources = resources.where(user_id: params[:user_id]) unless
        params[:user_id].blank?
    resources
  end

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
  # Returns a CSV representation of the given resources. Assessment questions
  # are excluded for performance reasons.
  #
  # @param resource Array of Resources
  #
  def self.as_csv(resources)
    # find the max number of one-to-many columns needed
    num_columns = { creator: 0, date: 0, subject: 0, extent: 0, note: 0 }
    resources.each do |resource|
      num_columns[:creator] = [resource.creators.length, num_columns[:creator]].max
      num_columns[:date] = [resource.resource_dates.length, num_columns[:date]].max
      num_columns[:subject] = [resource.subjects.length, num_columns[:subject]].max
      num_columns[:extent] = [resource.extents.length, num_columns[:extent]].max
      num_columns[:note] = [resource.resource_notes.length, num_columns[:note]].max
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
          (['Creator'] * num_columns[:creator]) +
          (['Date'] * num_columns[:date]) +
          ['Language'] +
          (['Subject'] * num_columns[:subject]) +
          (['Extent'] * num_columns[:extent]) +
          ['Rights'] +
          ['Description'] +
          (['Note'] * num_columns[:note]) +
          ['Created'] +
          ['Updated']
      resources.each do |resource|
        # can't use Resource.as_csv because we need to pad the one-to-many
        # properties with blanks
        csv << [resource.local_identifier] +
            [resource.name] +
            [resource.total_assessment_score * 100] +
            [resource.readable_resource_type] +
            [resource.parent ? resource.parent.name : nil] +
            [resource.format ? resource.format.name : nil] +
            [resource.readable_significance] +
            resource.creators.map { |r| r.name } + [nil] * (num_columns[:creator] - resource.creators.length) +
            resource.resource_dates.map { |r| r.as_dublin_core_string } + [nil] * (num_columns[:date] - resource.resource_dates.length) +
            [resource.language ? resource.language.english_name : nil] +
            resource.subjects.map { |s| s.name } + [nil] * (num_columns[:subject] - resource.subjects.length) +
            resource.extents.map { |e| e.name } + [nil] * (num_columns[:extent] - resource.extents.length) +
            [resource.rights] +
            [resource.description] +
            resource.resource_notes.map { |n| n.value } + [nil] * (num_columns[:note] - resource.resource_notes.length) +
            [resource.created_at.iso8601] +
            [resource.updated_at.iso8601]
      end
    end
  end

  ##
  # @return Array of all assessed items in a collection, regardless of depth
  # in the hierarchy.
  #
  def all_assessed_items
    all_children.select{ |x| x.resource_type == ResourceType::ITEM and
        x.assessment_complete }
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
          ['Assessment Type'] +
          ['Location'] +
          ['Resource Type'] +
          ['Parent Resource'] +
          ['Format'] +
          ['Format Ink/Media Type'] +
          ['Format Support Type'] +
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
          [(self.total_assessment_score * 100).round(2)] +
          [AssessmentType::name_for_type(self.assessment_type)] +
          [self.location.name] +
          [self.readable_resource_type] +
          [self.parent ? self.parent.name : nil] +
          [self.format ? self.format.name : nil] +
          [self.format_ink_media_type ? self.format_ink_media_type.name : nil] +
          [self.format_support_type ? self.format_support_type.name : nil] +
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

  def update_assessment_complete
    self.assessment_complete =
        (self.format and self.format.all_assessment_questions.any?) ?
            self.assessment_question_responses.length >=
                self.format.all_assessment_questions.length : false
    nil
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

  def validates_collections_not_assessable
    if self.resource_type == ResourceType::COLLECTION and
        self.assessment_question_responses.any?
      errors[:base] << 'Collections are not assessable.'
    end
  end

  def validates_not_child_of_item
    if parent and parent.resource_type != ResourceType::COLLECTION
      errors[:base] << 'Only collection resources can have sub-resources.'
    end
  end

  def validates_same_institution_as_user
    if user and !user.is_admin? and
        user.institution != self.location.repository.institution
      errors[:base] << 'Owning user must be of the same institution.'
    end
  end

end
