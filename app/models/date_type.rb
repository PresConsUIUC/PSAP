class DateType

  SINGLE = 0
  BULK = 1
  INCLUSIVE = 2
  SPAN = 2 # span == inclusive

  def self.all
    return 0..2
  end

  def self.name_for_type(type)
    case type
      when 0
        return 'Single'
      when 1
        return 'Bulk'
      when 2
        return 'Inclusive/Span'
    end
  end

end
