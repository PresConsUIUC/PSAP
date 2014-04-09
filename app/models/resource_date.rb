class DateRangeValidator < ActiveModel::Validator

  def validate(record)
    if record.begin_year && record.end_year
      if record.begin_month && (1..12).member?(record.begin_month) &&
          record.begin_day && (1..31).member?(record.begin_day)
        begin_time = Time.new(record.begin_year, record.begin_month, record.begin_day)
      elsif record.begin_month && (1..12).member?(record.begin_month)
        begin_time = Time.new(record.begin_year, record.begin_month)
      else
        begin_time = Time.new(record.begin_year)
      end

      if record.end_month && (1..12).member?(record.end_month) &&
          record.end_day && (1..31).member?(record.end_day)
        end_time = Time.new(record.end_year, record.end_month, record.end_day)
      elsif record.end_month && (1..12).member?(record.end_month)
        end_time = Time.new(record.end_year, record.end_month)
      else
        end_time = Time.new(record.end_year)
      end

      if begin_time >= end_time
        record.errors[:name] << 'Begin date must be earlier than end date.'
      end
    end

    if record.date_type == DateType::SINGLE && !record.year
      record.errors[:name] << 'Year is required for single dates.'
    end

    if record.date_type != DateType::SINGLE && (!record.begin_year || !record.end_year)
      record.errors[:name] << 'Begin and end years are required for date ranges.'
    end
  end

end

class ResourceDate < ActiveRecord::Base
  belongs_to :resource, inverse_of: :resource_dates

  validates :year, allow_blank: true,
            numericality: { greater_than_or_equal_to: -9999,
                            less_than_or_equal_to: Time.now.year }
  validates :month, allow_blank: true,
            numericality: { greater_than: 0, less_than: 13 }
  validates :day, allow_blank: true,
            numericality: { greater_than: 0, less_than: 32 }

  validates :begin_year, allow_blank: true,
            numericality: { greater_than_or_equal_to: -9999,
                            less_than_or_equal_to: Time.now.year }
  validates :begin_month, allow_blank: true,
            numericality: { greater_than: 0, less_than: 13 }
  validates :begin_day, allow_blank: true,
            numericality: { greater_than: 0, less_than: 32 }

  validates :end_year, allow_blank: true,
            numericality: { greater_than_or_equal_to: -9999,
                            less_than_or_equal_to: Time.now.year }
  validates :end_month, allow_blank: true,
            numericality: { greater_than: 0, less_than: 13 }
  validates :end_day, allow_blank: true,
            numericality: { greater_than: 0, less_than: 32 }

  validates :date_type, presence: true,
            inclusion: { in: DateType.all,
                         message: 'Must be a valid date type.' }
  validates :resource, presence: true

  include ActiveModel::Validations
  validates_with DateRangeValidator

  def readable_date_type
    case date_type
      when DateType::SINGLE
        'Single'
      when DateType::BULK
        'Bulk'
      when DateType::SPAN
        'Span'
    end
  end

end
