module ResourcesHelper

  def collection_hierarchy_options_for_select(location)
    collections = location.resources.
        where(resource_type: ResourceType::COLLECTION, parent_id: nil).
        order(:name)
    options = []
    collections.each do |collection|
      level = 0
      add_option_for_collection(collection, options, level)
    end
    options
  end

  def human_readable_date(resource_date)
    date = ''
    if resource_date.year
      date = "#{resource_date.year}"
      if resource_date.month
        date += "-#{resource_date.month}"
        if resource_date.day
          date += "-#{resource_date.day}"
        end
      end
    elsif resource_date.begin_year
      date += "#{resource_date.begin_year}"
      if resource_date.begin_month
        date += "#{resource_date.begin_month}"
        if resource_date.begin_day
          date += "#{resource_date.begin_day}"
        end
      end
      if resource_date.end_year
        date += " to #{resource_date.end_year}"
        if resource_date.end_month
          date += "#{resource_date.end_month}"
          if resource_date.end_day
            date += "#{resource_date.end_day}"
          end
        end
      end
    end
    date += " (#{resource_date.readable_date_type.downcase})"
  end

  def score_help(resource)
    assessment_score = (resource.assessment_question_score * 100).round(1)
    format_score = (resource.effective_format_score * 100).round(1)
    location_score = (resource.location.assessment_score * 100).round(1)

    text = '<p>The following formula is used to calculate a resource\'s '\
    'assessment score:</p>'\
    '<p><em>Assessment score &times; 0.5 + format score &times; 0.4 + '\
    'location score &times; 0.1</em></p>'\
    '<ul>'

    if resource.assessment_question_responses.length < 1
      text += "<li>This resource has not been assessed yet, which heavily "\
      "weighs down its score.</li>"
    else
      text += "<li>This resource's assessment score is "\
      "<strong>#{assessment_score}</strong>.</li>" # TODO: "this is good" etc.
    end

    if resource.format
      text += "<li>Its format score is <strong>#{format_score}</strong>.</li>" # TODO: "this is good" or "consider migrating..." etc.
    else
      text += "<li>It does not yet have a format specified, which heavily "\
      "weighs down its score. You can do this during the "\
      "#{link_to('assessment process', edit_resource_path(resource))}.</li>"
    end

    if resource.location.assessment_question_responses.length < 1
      text += "<li>Its location has not yet been assessed, which weighs down "\
      "its score.</li>"
    else
      text += "<li>Its location score is "\
      "<strong>#{location_score}</strong>.</li>" # TODO: "this is good" or "consider moving" etc.
    end

    text + '</ul>'
  end

  private

  def add_option_for_collection(collection, options, level)
    options << [raw(('&nbsp;&nbsp;&nbsp;&nbsp;' * level) +
                        (level > 0 ? raw('&#8627; ') : '') + collection.name),
                collection.id]
    collection.children.where(resource_type: ResourceType::COLLECTION).each do |child|
      add_option_for_collection(child, options, level + 1)
    end
  end

end
