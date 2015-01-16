class AssessmentType

  ITEM_LEVEL = 0
  SAMPLE = 1

  def self.all
    return 0..1
  end

  def self.name_for_type(type)
    case type
      when AssessmentType::ITEM_LEVEL
        'Item-Level'
      when AssessmentType::SAMPLE
        'Sample'
      else
        'Unknown'
    end
  end

end
