module FormatsHelper

  def format_hierarchy_options_for_select
    formats = Format.where(parent_id: nil).order(:name)
    options = []
    formats.each do |format|
      level = 0
      add_option_for_format(format, options, level)
    end
    options
  end

  def format_class_options
    options = []
    FormatClass.all.select{ |clazz|
      options << [ FormatClass.name_for_class(clazz), clazz ] }
    options.sort_by { |op| op[0] }
  end

  private

  def add_option_for_format(format, options, level)
    options << [raw(('&nbsp;&nbsp;&nbsp;&nbsp;' * level) +
                        (level > 0 ? raw('&#8627; ') : '') + format.name), format.id]
    format.children.order(:name).each do |child|
      add_option_for_format(child, options, level + 1)
    end
  end

end
