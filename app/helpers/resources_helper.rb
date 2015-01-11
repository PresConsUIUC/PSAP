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

  def score_help(resource)
    assessment_score = (resource.assessment_score * 100).round(1)
    format_score = (resource.format and resource.format.score) ?
        (resource.format.score * 100).round(1) : 0
    location_score = (resource.location.assessment_score * 100).round(1)

    text = '<p>The PSAP uses the following formula to calculate a resource\'s '\
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
      text += "<li>Its #{link_to('location', location_path(resource.location))}"\
      " has not yet been assessed, which weighs down its score.</li>"
    else
      text += "<li>Its #{link_to('location', location_path(resource.location))}"\
      " score is <strong>#{location_score}</strong>.</li>" # TODO: "this is good" or "consider moving" etc.
    end

    text + '</ul>'
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
