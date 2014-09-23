class Format < ActiveRecord::Base
  has_many :assessment_questions, inverse_of: :format
  has_many :children, class_name: 'Format', foreign_key: 'parent_id',
           inverse_of: :parent, dependent: :destroy
  has_many :resources, inverse_of: :format, dependent: :restrict_with_exception
  has_many :temperature_ranges, inverse_of: :format, dependent: :destroy
  has_and_belongs_to_many :events
  belongs_to :parent, class_name: 'Format', inverse_of: :children

  accepts_nested_attributes_for :temperature_ranges, allow_destroy: true

  validates :format_subtype, allow_blank: true,
            inclusion: { in: FormatSubtype.all,
                         message: 'Must be a valid format subtype.' }
  validates :format_type, presence: true,
            inclusion: { in: FormatType.all,
                         message: 'Must be a valid format type.' }
  validates :score, presence: true, numericality: {
      greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }

  validate :validates_sequential_ranges

  def validates_sequential_ranges
    ranges = self.temperature_ranges.sort_by { |obj| obj.min_temp_f or 0 }
    prev_range = nil
    ranges.each do |range|
      if prev_range && range.min_temp_f && range.min_temp_f - prev_range.max_temp_f != 1
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

    AssessmentQuestion.where('format_id IN (?)', format_ids)
  end

  def as_json(options = { })
    super((options || { }).merge(
              { :methods => [:format_subtype, :readable_format_subtype] }))
  end

  def readable_format_subtype
    FormatSubtype.name_for_subtype(format_subtype)
  end

end
