class FormatType

  AV = 0
  PHOTO = 1
  IMAGE = 1
  UNBOUND_PAPER = 2
  BOUND_PAPER = 3

  def self.all
    return (0..3)
  end

  def self.name_for_type(type)
    case type
      when FormatType::AV
        'A/V'
      when FormatType::PHOTO
        'Photo/Image'
      when FormatType::IMAGE
        'Photo/Image'
      when FormatType::UNBOUND_PAPER
        'Paper-Unbound'
      when FormatType::BOUND_PAPER
        'Paper-Bound/Book'
    end
  end

end
