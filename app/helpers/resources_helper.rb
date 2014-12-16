module ResourcesHelper

  def chart_for_collection(resource)
    raw('<svg></svg>')
  end

  def human_readable_date(resource_date)
    if resource_date.year
      "#{resource_date.year} (#{resource_date.readable_date_type.downcase})"
    elsif resource_date.begin_year || resource_date.end_year
      "#{resource_date.begin_year}-#{resource_date.end_year} "\
        "(#{resource_date.readable_date_type.downcase})"
    end
  end

  def resource_hierarchy_options_for_select(location)
    resources = location.resources.where(parent_id: nil).order(:name)
    options = []
    resources.each do |resource|
      level = 0
      add_option_for_resource(resource, options, level)
    end
    options
  end

  private

  def add_option_for_resource(resource, options, level)
    options << [raw(('&nbsp;&nbsp;&nbsp;&nbsp;' * level) +
                        (level > 0 ? raw('&#8627; ') : '') + resource.name), resource.id]
    resource.children.each do |child|
      add_option_for_resource(child, options, level + 1)
    end
  end

end
