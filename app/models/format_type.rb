##
# Formats have a type and a subtype. The type is the main format category,
# appearing in the resource assessment form as a set of radio buttons that
# toggle the contents of the first format <select> menu.
class FormatType # TODO: rename to FormatClass (#124)

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

  def self.type_for_name(name)
    if %w(audiovisual a/v).include?(name.downcase)
      FormatType::AV
    elsif name[0..2].downcase == 'pho'
      FormatType::PHOTO
    elsif name.downcase.include?('unbound')
      FormatType::UNBOUND_PAPER
    elsif name.downcase.include?('bound')
      FormatType::BOUND_PAPER
    end
  end

end
