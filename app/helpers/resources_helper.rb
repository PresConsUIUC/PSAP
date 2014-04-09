module ResourcesHelper

  def human_readable_date(resource_date)
    if resource_date.year
      "#{resource_date.year} (#{resource_date.readable_date_type.downcase})"
    elsif resource_date.begin_year || resource_date.end_year
      "#{resource_date.begin_year}-#{resource_date.end_year} "\
        "(#{resource_date.readable_date_type.downcase})"
    end
  end

end
