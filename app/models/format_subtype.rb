##
# Formats have a type and a subtype. The subtype appears in the resource
# assessment form as an <optgroup> within the format <select> menus.
class FormatSubtype

  MONOCHROME_PRINT = 0
  COLOR_PRINT = 1
  INSTANT_PHOTO = 2
  GLASS_NEGATIVE = 3
  PLASTIC_FILM_NEGATIVE = 4
  GLASS_SLIDE = 5
  PLASTIC_FILM_SLIDE = 6
  PLASTIC_FILM = 7
  PAPER = 8
  MIXED = 9

  ARCH_DRAWING_REPRODUCTION = 10
  OFFICE_COPY_PRINT = 11
  ORIGINAL_DOCUMENT = 12

  def self.all
    return (0..12)
  end

  def self.name_for_subtype(type)
    case type
      when FormatSubtype::ARCH_DRAWING_REPRODUCTION
        'Architectural Drawing Reproduction'
      when FormatSubtype::COLOR_PRINT
        'Color Print'
      when FormatSubtype::GLASS_NEGATIVE
        'Glass Negative'
      when FormatSubtype::GLASS_SLIDE
        'Glass Slide'
      when FormatSubtype::INSTANT_PHOTO
        'Instant Photo'
      when FormatSubtype::MIXED
        'Mixed'
      when FormatSubtype::MONOCHROME_PRINT
        'Monochrome Print'
      when FormatSubtype::OFFICE_COPY_PRINT
        'Office Copy/Print'
      when FormatSubtype::ORIGINAL_DOCUMENT
        'Original Document'
      when FormatSubtype::PAPER
        'Paper'
      when FormatSubtype::PLASTIC_FILM
        'Plastic Film'
      when FormatSubtype::PLASTIC_FILM_NEGATIVE
        'Plastic Film Negative'
      when FormatSubtype::PLASTIC_FILM_SLIDE
        'Plastic Film Slide'
    end
  end

end
