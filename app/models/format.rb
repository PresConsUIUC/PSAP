class Format < ActiveRecord::Base
  has_many :children, class_name: 'Format', foreign_key: 'parent_id',
           inverse_of: :parent, dependent: :destroy
  has_many :format_ink_media_types, inverse_of: :format
  has_many :format_support_types, inverse_of: :format
  has_many :humidity_ranges, inverse_of: :format, dependent: :destroy
  has_many :resources, inverse_of: :format, dependent: :nullify
  has_many :temperature_ranges, inverse_of: :format, dependent: :destroy
  has_and_belongs_to_many :assessment_questions
  has_and_belongs_to_many :events
  belongs_to :parent, class_name: 'Format', inverse_of: :children

  validates :format_class, presence: true,
            inclusion: { in: FormatClass.all,
                         message: 'Must be a valid format class.' }
  validates :name, presence: true, length: { maximum: 255 }

  validate :validates_temperature_ranges

  def validates_temperature_ranges
    ranges = self.temperature_ranges.sort_by { |obj| obj.min_temp_f or 0 }
    prev_range = nil
    ranges.each do |range|
      if prev_range and range.min_temp_f and
          range.min_temp_f - prev_range.max_temp_f != 1
        errors[:base] << ('The minimum temperature must be one '\
        'degree greater than the maximum temperature of the next lower range.')
      end
      prev_range = range
    end
  end

  ##
  # Returns all assessment questions associated with the format, including
  # questions associated with any of its ancestors.
  #
  def all_assessment_questions
    def collect_ancestor_ids(format, all_ids)
      all_ids << format.id
      collect_ancestor_ids(format.parent, all_ids) if format.parent
    end
    format_ids = []
    collect_ancestor_ids(self, format_ids)

    AssessmentQuestion.joins(:formats).
        where('assessment_questions_formats.format_id IN (?)', format_ids)
  end

  ##
  # Returns true if the format is Paper-Unbound --> Original Document or
  # Paper-Bound, as resources will have required ink/media type and support
  # type properties for these two formats only.
  #
  # @return boolean
  #
  def requires_type_vectors?
    [159, 160].include?(self.fid)
  end

end
