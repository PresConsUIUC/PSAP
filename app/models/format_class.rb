##
# The format class is the broadest category in which formats reside.
#
class FormatClass

  AV = 0
  PHOTO = 1
  IMAGE = 1
  UNBOUND_PAPER = 2
  BOUND_PAPER = 3
  OBJECT = 4

  def self.all
    return (0..4)
  end

  def self.name_for_class(clazz)
    case clazz
      when FormatClass::AV
        'A/V'
      when FormatClass::PHOTO
        'Photo/Image'
      when FormatClass::IMAGE
        'Photo/Image'
      when FormatClass::UNBOUND_PAPER
        'Paper-Unbound'
      when FormatClass::BOUND_PAPER
        'Paper-Bound/Book'
      when FormatClass::OBJECT
        'Object'
    end
  end

  def self.class_for_name(name)
    if %w(audiovisual a/v).include?(name.downcase)
      FormatClass::AV
    elsif name[0..5].downcase == 'object'
      FormatClass::OBJECT
    elsif name[0..2].downcase == 'pho'
      FormatClass::PHOTO
    elsif name.downcase.include?('unbound')
      FormatClass::UNBOUND_PAPER
    elsif name.downcase.include?('bound')
      FormatClass::BOUND_PAPER
    end
  end

end
