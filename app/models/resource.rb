##
# A Resource exists within a Location. It has a resource_type property which
# must be set to either Resource::Type::ITEM or Resource::Type::COLLECTION.
# Collections can contain zero or more child resources. Formats, ink/media
# types, and support types can be ascribed only to items.
#
# Items are assessable, but collections are not. A collection's assessment
# score is the mean of the item scores contained within.
#
class Resource < ApplicationRecord

  class Significance
    LOW = 0
    MODERATE = 0.5
    HIGH = 1

    def self.all
      return [0, 0.5, 1]
    end
  end

  class Type
    COLLECTION = 0
    ITEM = 1

    def self.all
      return (0..1)
    end
  end

  MAX_NAME_LENGTH = 255

  # When adding/removing properties or associations, update both .as_csv and
  # ::as_csv.

  include Assessable
  include Introspection

  # When adding/removing has_many, has_one, or habtm associations, update
  # dup and update_submodels as well!
  has_many :assessment_question_responses, inverse_of: :resource,
           dependent: :destroy
  has_many :children, -> { order(:name) }, class_name: 'Resource',
           foreign_key: 'parent_id', inverse_of: :parent, dependent: :destroy
  has_many :creators, inverse_of: :resource, dependent: :destroy
  has_many :extents, inverse_of: :resource, dependent: :destroy
  has_many :resource_dates, inverse_of: :resource, dependent: :destroy
  has_many :resource_notes, inverse_of: :resource, dependent: :destroy
  has_many :subjects, inverse_of: :resource, dependent: :destroy
  belongs_to :format, inverse_of: :resources, optional: true
  belongs_to :format_ink_media_type, inverse_of: :resources, optional: true
  belongs_to :format_support_type, inverse_of: :resources, optional: true
  belongs_to :language, inverse_of: :resources, optional: true
  belongs_to :location, inverse_of: :resources
  belongs_to :parent, class_name: 'Resource', inverse_of: :children, optional: true
  belongs_to :user, inverse_of: :resources, optional: true

  accepts_nested_attributes_for :assessment_question_responses
  accepts_nested_attributes_for :creators, allow_destroy: true
  accepts_nested_attributes_for :extents, allow_destroy: true
  accepts_nested_attributes_for :resource_dates, allow_destroy: true
  accepts_nested_attributes_for :resource_notes, allow_destroy: true
  accepts_nested_attributes_for :subjects, allow_destroy: true

  before_validation :prune_empty_submodels
  before_validation :prune_irrelevant_models
  before_validation :sync_location_with_parent

  validates :assessment_type, allow_blank: true,
            inclusion: { in: Assessment::Type.all,
                         message: 'must be a valid assessment type' }
  validates :location, presence: true
  validates :name, presence: true, length: { maximum: MAX_NAME_LENGTH }
  validates :resource_type, inclusion: { in: Resource::Type.all,
                         message: 'must be a valid resource type' }
  validates :significance, allow_blank: true,
            inclusion: { in: Resource::Significance.all,
                         message: 'must be a valid resource significance' }
  validates :user, presence: true

  validate :validate_item_children
  validate :validate_not_child_of_item
  validate :validate_user

  validates_uniqueness_of :name, scope: :parent_id

  before_save :update_assessment_score, :update_assessment_complete

  ##
  # @param institution [Institution]
  # @param params [ActionController::Parameters]
  # @return [ActiveRecord::Relation<Resource>]
  #
  def self.all_matching_query(institution, params)
    params = params.symbolize_keys
    resources = Resource.all.distinct
                    .joins('INNER JOIN locations ON resources.location_id = locations.id')

    # assessed
    if params[:assessed] == '1'
      resources = resources.where(assessment_complete: true)
    elsif params[:assessed] == '0'
      resources = resources.where(assessment_complete: false)
    end
    # format_id
    resources = resources.where(format_id: params[:format_id]) if
        params[:format_id].present?
    # language_id
    if params[:language_id].present?
      if params[:language_id].to_i == institution.language.id
        resources = resources.where('language_id = ? OR language_id IS NULL',
                                    params[:language_id])
      else
        resources = resources.where(language_id: params[:language_id])
      end
    end
    # repository_id
    if params[:repository_id].present?
      resources = resources.joins("INNER JOIN repositories ON locations.repository_id = repositories.id "\
                                  "AND repositories.id = #{params[:repository_id]}")
    else
      resources = resources.joins('INNER JOIN repositories ON locations.repository_id = repositories.id')
    end
    resources = resources.joins("INNER JOIN institutions ON repositories.institution_id = institutions.id "\
                                "AND institutions.id = #{institution.id}")
    # q
    if params[:q].present?
      q = "%#{params[:q].strip.downcase}%"
      resources = resources.
          joins('LEFT JOIN resource_notes ON resource_notes.resource_id = resources.id').
          joins('LEFT JOIN subjects ON subjects.resource_id = resources.id').
          where('LOWER(resources.description) LIKE ? '\
          'OR LOWER(resources.local_identifier) LIKE ? '\
          'OR LOWER(resources.name) LIKE ? '\
          'OR LOWER(resources.rights) LIKE ? '\
          'OR LOWER(resource_notes.value) LIKE ? '\
          'OR LOWER(subjects.name) LIKE ?',
                q, q, q, q, q, q)
    end
    # resource_type
    resources = resources.where(resource_type: params[:resource_type]) if
        params[:resource_type].present? and params[:resource_type] != 'any'
    # score/score_direction
    if params[:score].present? and params[:score_direction].present?
      score = params[:score].to_f / 100
      direction = params[:score_direction] == 'greater' ? '>' : '<'
      resources = resources.
          where("resources.assessment_score #{direction} #{score}")
    end
    # user_id
    resources = resources.where(user_id: params[:user_id]) if
        params[:user_id].present?
    resources
  end

  ##
  # @param ead [String] EAD XML string
  # @param user [User]
  # @return [Resource]
  # @raises [Nokogiri::XML::SyntaxError]
  #
  def self.from_ead(ead, user)
    doc = Nokogiri::XML(ead) { |config| config.strict }
    ead_ns = { 'ead' => 'urn:isbn:1-931666-22-9' }
    params = {}

    # creators
    params[:creators_attributes] = []
    doc.xpath('//ead:archdesc/ead:did/ead:origination[@label = \'creator\']', ead_ns).each do |element|
      element.children&.each do |child|
        name = child.text.squish.strip
        params[:creators_attributes] << { name: name } if name.present?
      end
    end

    # dates
    params[:resource_dates_attributes] = []
    doc.xpath('//ead:archdesc/ead:did/ead:unitdate', ead_ns).each do |element|
      date_struct = {}

      case element.attribute('type').text
        when 'inclusive'
          date_struct[:date_type] = DateType::INCLUSIVE
        when 'bulk'
          date_struct[:date_type] = DateType::BULK
        when 'span'
          date_struct[:date_type] = DateType::SPAN
        when 'single'
          date_struct[:date_type] = DateType::SINGLE
      end

      date_text = element.attribute('normal').text
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

      params[:resource_dates_attributes] << date_struct
    end

    # description
    doc.xpath('//ead:archdesc/ead:did/ead:abstract[1]', ead_ns).each do |element|
      params[:description] = element.text.squish
    end

    # extents
    params[:extents_attributes] = []
    doc.xpath('//ead:archdesc/ead:did/ead:physdesc/ead:extent', ead_ns).each do |extent|
      params[:extents_attributes] << { name: extent.text.squish }
    end

    # language (PSAP supports only one)
    doc.xpath('//ead:archdesc/ead:did/ead:langmaterial/ead:language[1]', ead_ns).each do |element|
      lang = Language.find_by_iso639_2_code(element.attribute('langcode').text)
      params[:language_id] = lang.id if lang
    end

    # local identifier
    doc.xpath('//ead:archdesc/ead:did/ead:unitid[1]', ead_ns).each do |element|
      params[:local_identifier] = element.text.squish
    end

    # name
    doc.xpath('//ead:archdesc/ead:did/ead:unittitle[1]', ead_ns).each do |element|
      params[:name] = element.text.squish
    end

    # resource type
    doc.xpath('//ead:archdesc', ead_ns).each do |element|
      case element.attribute('level').text.strip
        when 'collection'
          params[:resource_type] = Resource::Type::COLLECTION
        else
          params[:resource_type] = Resource::Type::ITEM
      end
    end

    # subjects
    params[:subjects_attributes] = []
    doc.xpath('//ead:archdesc/ead:controlaccess/*', ead_ns).each do |element|
      params[:subjects_attributes] << { name: element.text.squish }
    end

    # user
    params[:user_id] = user.id

    Resource.new(params)
  end

  ##
  # Returns a CSV representation of the given resources. Assessment questions
  # are excluded.
  #
  # @param resources [Enumerable<Resource>]
  #
  def self.as_csv(resources)
    # find the max number of one-to-many columns needed
    num_columns = { creator: 0, date: 0, subject: 0, extent: 0, note: 0 }
    resources.each do |resource|
      num_columns[:creator] = [resource.creators.count, num_columns[:creator]].max
      num_columns[:date]    = [resource.resource_dates.count, num_columns[:date]].max
      num_columns[:subject] = [resource.subjects.count, num_columns[:subject]].max
      num_columns[:extent]  = [resource.extents.count, num_columns[:extent]].max
      num_columns[:note]    = [resource.resource_notes.count, num_columns[:note]].max
    end

    # CSV format is defined in G:|AcqCatPres\PSAP\Design\CSV
    # Can't use Resource.as_csv here because we need to pad the one-to-many
    # properties with blanks. So, when updating this, Resource.as_csv must be
    # updated as well.
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
        if resource.language
          language_name = resource.language.english_name
        elsif resource.location.repository.institution.language
          language_name = resource.location.repository.institution.language.english_name
        else
          language_name = 'Not Specified'
        end
        csv << [resource.local_identifier] +
            [resource.name] +
            [(resource.assessment_score * 100).round(2)] +
            [Assessment::Type::name_for_type(resource.assessment_type)] +
            [resource.location.name] +
            [resource.readable_resource_type] +
            [resource.parent ? resource.parent.name : nil] +
            [resource.format ? resource.format_tree.map(&:name).join(' > ') : nil] +
            [resource.format_ink_media_type ? resource.format_ink_media_type.name : nil] +
            [resource.format_support_type ? resource.format_support_type.name : nil] +
            [resource.readable_significance] +
            resource.creators.pluck(:name) + [nil] * (num_columns[:creator] - resource.creators.length) +
            resource.resource_dates.map(&:as_dublin_core_string) + [nil] * (num_columns[:date] - resource.resource_dates.length) +
            [language_name] +
            resource.subjects.pluck(:name) + [nil] * (num_columns[:subject] - resource.subjects.length) +
            resource.extents.pluck(:name) + [nil] * (num_columns[:extent] - resource.extents.length) +
            [resource.rights] +
            [resource.description] +
            resource.resource_notes.pluck(:value) + [nil] * (num_columns[:note] - resource.resource_notes.length) +
            [resource.created_at.iso8601] +
            [resource.updated_at.iso8601]
      end
    end
  end

  ##
  # Used by `Location.import()`.
  #
  # @param struct [Hash]
  # @param location_id [Integer]
  # @return [Resource]
  #
  def self.import(struct, location_id, parent_id = nil)
    res = Resource.create!(name: struct['name'],
                           description: struct['description'],
                           location_id: location_id,
                           parent_id: parent_id,
                           resource_type: struct['resource_type'],
                           format_id: struct['format_id'],
                           user_id: struct['user_id'],
                           local_identifier: struct['local_identifier'],
                           date_type: struct['date_type'],
                           assessment_id: struct['assessment_id'],
                           rights: struct['rights'],
                           language_id: struct['language_id'],
                           assessment_score: struct['assessment_score'],
                           assessment_complete: struct['assessment_complete'],
                           significance: struct['significance'],
                           format_ink_media_type_id: struct['format_ink_media_type_id'],
                           format_support_type_id: struct['format_support_type_id'],
                           assessment_type: struct['assessment_type'],
                           created_at: struct['created_at'],
                           updated_at: struct['updated_at'])

    struct['assessment_question_responses'].each do |response|
      res.assessment_question_responses.build(
          assessment_question_option_id: response['assessment_question_option_id'],
          assessment_question_id: response['assessment_question_id'],
          created_at: response['created_at'],
          updated_at: response['updated_at'])
    end
    struct['creators'].each do |creator|
      res.creators.build(name: creator['name'],
                         resource_id: res.id,
                         creator_type: creator['creator_type'],
                         created_at: creator['created_at'],
                         updated_at: creator['updated_at'])
    end
    struct['extents'].each do |extent|
      res.extents.build(name: extent['name'],
                        resource_id: extent['resource_id'])
    end
    struct['resource_dates'].each do |date|
      res.resource_dates.build(resource_id: res.id,
                               date_type: date['date_type'],
                               begin_year: date['begin_year'],
                               begin_month: date['begin_month'],
                               begin_day: date['begin_day'],
                               end_year: date['end_year'],
                               end_month: date['end_month'],
                               end_day: date['end_day'],
                               year: date['year'],
                               month: date['month'],
                               day: date['day'])
    end
    struct['resource_notes'].each do |note|
      res.resource_notes.build(value: note['value'],
                               created_at: note['created_at'],
                               updated_at: note['updated_at'])
    end
    struct['subjects'].each do |subject|
      res.subjects.build(name: subject['name'],
                         created_at: subject['created_at'],
                         updated_at: subject['updated_at'])
    end
    res.save!

    struct['resources'].each do |subresource|
      Resource.import(subresource, location_id, res.id)
    end

    res
  end

  ##
  # @return [Enumerable<Resource>] All assessed items in a collection,
  #         regardless of depth in the tree.
  #
  def all_assessed_items
    sql = 'WITH RECURSIVE q AS (
        SELECT h, 1 AS level, ARRAY[id] AS breadcrumb
        FROM resources h
        WHERE id = $1
        UNION ALL
        SELECT hi, q.level + 1 AS level, breadcrumb || id
        FROM q
        JOIN resources hi
          ON hi.parent_id = (q.h).id
      )
      SELECT (q.h).id
      FROM q
      WHERE (q.h).resource_type = $2 AND (q.h).assessment_complete = $3
      ORDER BY breadcrumb'
    values = [[ nil, self.id ], [ nil, Resource::Type::ITEM ], [ nil, true ]]

    results = ActiveRecord::Base.connection.exec_query(sql, 'SQL', values)
    Resource.where('id IN (?)', results
                                    .reject{ |row| row['id'] == self.id }
                                    .map{ |row| row['id'] })
  end

  ##
  # @return [Enumerable<Resource>] All resources that are children of the
  #         instance at any level in the tree.
  #
  def all_children
    sql = 'WITH RECURSIVE q AS (
        SELECT h, 1 AS level, ARRAY[id] AS breadcrumb
        FROM resources h
        WHERE id = $1
        UNION ALL
        SELECT hi, q.level + 1 AS level, breadcrumb || id
        FROM q
        JOIN resources hi
          ON hi.parent_id = (q.h).id
      )
      SELECT (q.h).id
      FROM q
      ORDER BY breadcrumb'
    values = [[ nil, self.id ]]

    results = ActiveRecord::Base.connection.exec_query(sql, 'SQL', values)
    Resource.where('id IN (?)', results
                                    .reject{ |row| row['id'] == self.id }
                                    .map{ |row| row['id'] })
  end

  ##
  # @return [Enumerable<Resource>] All parents in order from closest to
  #                                farthest.
  #
  def all_parents
    parents = []
    p = self.parent
    while p
      parents << p
      p = p.parent
    end
    parents
  end

  def as_csv
    questions = []
    responses = []
    self.assessment_question_responses.each_with_index do |response, index|
      questions << "Q#{index + 1}: #{response.assessment_question.name}"
      responses << response.assessment_question_option.name
    end

    # The CSV format is defined in G:\AcqCatPres\PSAP\Design\CSV
    # When updating this, Resource::as_csv must be updated as well.
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
          [(self.assessment_score * 100).round(2)] +
          [Assessment::Type::name_for_type(self.assessment_type)] +
          [self.location.name] +
          [self.readable_resource_type] +
          [self.parent ? self.parent.name : nil] +
          [self.format ? self.format_tree.map(&:name).join(' > ') : nil] +
          [self.format_ink_media_type ? self.format_ink_media_type.name : nil] +
          [self.format_support_type ? self.format_support_type.name : nil] +
          [self.readable_significance] +
          self.creators.pluck(:name) +
          self.resource_dates.map(&:as_dublin_core_string) +
          [self.language ? self.language.english_name : nil] +
          self.subjects.pluck(:name) +
          self.extents.pluck(:name) +
          [self.rights] +
          [self.description] +
          self.resource_notes.pluck(:value) +
          [self.created_at.iso8601] +
          [self.updated_at.iso8601] +
          responses
    end
  end

  ##
  # Returns a hash containing statistics of all assessed items in the
  # collection.
  #
  # @return [Hash] with :mean, :median, :low, and :high keys
  #
  def assessed_item_statistics
    stats           = { mean: 0, median: 0, low: nil, high: 0 }
    all_items       = all_assessed_items
    all_items_count = all_items.count
    if all_items_count < 1
      return nil
    end

    all_items.each do |item|
      stats[:high] = item.assessment_score if item.assessment_score > stats[:high]
      stats[:low]  = item.assessment_score if
          stats[:low].nil? or item.assessment_score < stats[:low]
    end
    all_scores     = all_items.pluck(:assessment_score)
    stats[:mean]   = all_scores.sum.to_f / all_items_count.to_f
    sorted         = all_scores.sort
    len            = sorted.length
    stats[:median] = (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
    stats
  end

  ##
  # @return [Float] between 0 and 1
  #
  def assessment_percent_complete
    if self.format
      # Technically this is not 100% accurate as it doesn't factor in child
      # questions. But it's 99% accurate and much less expensive.
      format_aqs = self.format.all_assessment_questions.reject(&:parent)
      if format_aqs.any?
        return [1, self.assessment_question_responses.length /
                     format_aqs.length.to_f].min
      end
    end
    0.0
  end

  ##
  # Returns the total score for the given top-level question, taking child
  # question responses into account.
  #
  # @param top_level_q [AssessmentQuestion]
  # @return [Float] between 0 and 1
  #
  def assessment_question_score(top_level_q)
    return nil if top_level_q.parent_id.present?
    score = 0.0
    response = self.assessment_question_responses.
        select{ |r| r.assessment_question == top_level_q }.first
    if response
      score = response.assessment_question_option.value
      if top_level_q.children.any?
        child_score = 0.0
        any_child_responses = false
        top_level_q.children.each do |child_q|
          child_response = self.assessment_question_responses.
              select{ |r| r.assessment_question == child_q }.first
          if child_response
            child_score += child_response.assessment_question_option.value
            any_child_responses = true
          end
        end
        score *= child_score if any_child_responses
      end
    end
    score * response.assessment_question.weight
  end

  ##
  # @return [Enumerable<AssessmentQuestion>] All assessment questions that have
  #                                          been answered for this resource.
  # @see top_level_assessment_questions()
  #
  def assessment_questions
    assessment_question_responses.map(&:assessment_question).uniq
  end

  ##
  # @return [ActiveRecord::Relation<Resource>]
  #
  def collections
    self.children.where(resource_type: Resource::Type::COLLECTION)
  end

  ##

  # Overrides parent to intelligently clone a resource. This implementation
  # does NOT clone child resources.
  #
  # @param omit_assessment_questions [Boolean]
  #
  def dup(omit_assessment_questions = false)
    clone = super()
    unless omit_assessment_questions
      self.assessment_question_responses.each do |response|
        cloned_response = response.dup
        cloned_response.assessment_question = response.assessment_question
        cloned_response.assessment_question_option = response.assessment_question_option
        cloned_response.location = response.location
        cloned_response.institution = response.institution
        cloned_response.resource = response.resource
        clone.assessment_question_responses << cloned_response
      end
    end
    self.creators.each { |c| clone.creators << c.dup }
    self.extents.each { |c| clone.extents << c.dup }
    self.resource_dates.each { |c| clone.resource_dates << c.dup }
    self.resource_notes.each { |c| clone.resource_notes << c.dup }
    self.subjects.each { |c| clone.subjects << c.dup }

    prefix = 'Clone of '
    (1..999).each do |i|
      proposed_name = prefix + self.name[0..(MAX_NAME_LENGTH - 1 - prefix.length * i)]
      unless Resource.find_by_name(proposed_name)
        clone.name = proposed_name
        break
      end
    end

    clone
  end

  ##
  # @return [float] between 0 and 1
  #
  def effective_format_score
    score = 0.0
    if self.format
      score = self.format.score
      if self.format.format_class == FormatClass::BOUND_PAPER or
          self.format.fid == 159 # Unbound Paper -> Original Document
        if self.format_support_type and self.format_ink_media_type
          score = self.format_support_type.score * 0.6 +
              self.format_ink_media_type.score * 0.4
        end
      end
    end
    score
  end

  ##
  # @return [float] between 0 and 1
  #
  def effective_humidity_score
    score = 0.0
    if self.format
      location_range = self.location.humidity_range
      if location_range
        format_range = self.format.humidity_ranges.where(
            min_rh: location_range.min_rh,
            max_rh: location_range.max_rh).first
        score = format_range.score if format_range
      end
    end
    score
  end

  ##
  # @return [float] between 0 and 1
  #
  def effective_temperature_score
    score = 0.0
    if self.format
      format_range = self.format.temperature_range_in_location(self.location)
      score = format_range.score if format_range
    end
    score
  end

  ##
  # Returns a filename in the following order of precedence:
  #
  # 1. The local identifier
  # 2. The string "resource-" + database ID
  # 3. The string "resource"
  #
  # This is just a base name, with no extension, and may contain filesystem-
  # incompatible characters. Mostly it's intended to be used in a
  # Content-Disposition HTTP response header.
  #
  # @return [String]
  #
  def filename
    class_name = self.class.to_s.downcase
    if self.local_identifier.present?
      self.local_identifier
    elsif self.id.present?
      "#{class_name}-#{self.id.to_s}"
    else
      class_name
    end
  end

  ##
  # @return [Enumerable<Format>] The assigned format and all of its parents in
  #                              order of most distant to closest. Or, if no
  #                              format is assigned, an empty array.
  #
  def format_tree
    tree = []
    if self.format
      tree << self.format
      p = self.format.parent
      while p
        tree << p
        p = p.parent
      end
    end
    tree.reverse
  end

  ##
  # Exports all of an instance's associated content.
  #
  # @see `Institution.full_export_as_json()`
  # @return [Hash]
  #
  def full_export_as_json
    struct = self.as_json
    struct[:assessment_question_responses] =
        self.assessment_question_responses.map(&:as_json)
    struct[:creators]       = self.creators.map(&:as_json)
    struct[:extents]        = self.extents.map(&:as_json)
    struct[:resource_dates] = self.resource_dates.map(&:as_json)
    struct[:resource_notes] = self.resource_notes.map(&:as_json)
    struct[:subjects]       = self.subjects.map(&:as_json)
    struct[:resources]      = self.children.map(&:full_export_as_json)
    struct
  end

  ##
  # @return [Float] Assessment score of the instance itself, excluding location,
  #                 format, etc.
  #
  def isolated_assessment_score
    question_score = 0.0
    assessment_question_responses
        .map(&:assessment_question)
        .select{ |r| r.parent_id.nil? }
        .uniq
        .each do |top_q|
      question_score += assessment_question_score(top_q)
    end
    # scores are pre-weighted; max is 50 so have to multiply by 2
    (question_score / 100) * 2
  end

  ##
  # Submitted edit forms will include empty submodels such as creator, extent,
  # etc. This method will remove them.
  #
  def prune_empty_submodels
    self.creators = self.creators.select{ |c| !c.name.blank? }
    self.extents = self.extents.select{ |e| !e.name.blank? }
    self.resource_dates = self.resource_dates.select{ |r| !r.year.blank? or !r.begin_year.blank? }
    self.resource_notes = self.resource_notes.select{ |r| !r.value.blank? }
    self.subjects = self.subjects.select{ |s| !s.name.blank? }
  end

  def prune_irrelevant_models
    if self.resource_type == Resource::Type::COLLECTION
      self.format                = nil
      self.format_ink_media_type = nil
      self.format_support_type   = nil
      self.assessment_question_responses.destroy_all
      self.assessment_complete   = nil
      self.assessment_type       = nil
    end
    if self.format and !self.format.requires_type_vectors?
      self.format_ink_media_type = nil
      self.format_support_type   = nil
    end
  end

  def readable_resource_type
    case resource_type
      when Resource::Type::COLLECTION
        'Collection'
      when Resource::Type::ITEM
        'Item'
    end
  end

  def readable_significance
    case significance
      when Resource::Significance::LOW
        'Low'
      when Resource::Significance::MODERATE
        'Moderate'
      when Resource::Significance::HIGH
        'High'
    end
  end

  def sync_location_with_parent
    self.location = self.parent.location if self.parent
  end

  ##
  # Overrides Assessable mixin
  #
  def update_assessment_complete
    self.assessment_complete = (self.assessment_percent_complete == 1)
    nil
  end

  ##
  # Overrides the Assessable mixin to assign the effective assessment score
  # (taking into account location, format, etc.) to `assessment_score`. For
  # collections, assigns the average score of all child resources.
  #
  # See https://github.com/PresConsUIUC/PSAP/wiki/Scoring
  #
  def update_assessment_score
    if self.resource_type == Resource::Type::COLLECTION
      scores = self.all_assessed_items.pluck(:assessment_score).select(&:present?)
      self.assessment_score = scores.length > 0 ?
                                  scores.sum / scores.length.to_f : 0.0
    else
      self.assessment_score = isolated_assessment_score * 0.5 +
          self.effective_format_score * 0.4 +
          self.location.assessment_score * 0.05 +
          self.effective_temperature_score * 0.025 +
          self.effective_humidity_score * 0.025
    end
  end

  private

  def self.ead_date_to_ymd_hash(date)
    date = date.split('-')
    parts = {}
    parts[:day]   = date[2].to_i if date.length > 2
    parts[:month] = date[1].to_i if date.length > 1
    parts[:year]  = date[0].to_i
    parts
  end

  def validate_item_children
    if self.resource_type == Resource::Type::ITEM and self.children.count > 0
      errors[:base] << 'Non-empty collections cannot be changed into items.'
    end
  end

  def validate_not_child_of_item
    if parent and parent.resource_type != Resource::Type::COLLECTION
      errors[:base] << 'Only collection resources can have sub-resources.'
    end
  end

  def validate_user
    this_inst = self.location&.repository&.institution
    if this_inst
      if !self.user&.is_admin? and this_inst != self.user&.institution
        errors[:base] << 'Owning user must belong to the same institution as '\
          'the resource\'s location\'s repository.'
      end
    end
  end

end
