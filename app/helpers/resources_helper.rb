module ResourcesHelper

  def collection_hierarchy_options_for_select(location)
    collections = location.resources.
        where(resource_type: Resource::Type::COLLECTION, parent_id: nil).
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
    return date unless resource_date
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

  ##
  # @param resources [Enumerable<Resource>] Return value of
  #                                         Resource.children_as_tree().
  # @param options [Hash]
  # @option options [Boolean] :show_checkboxes
  # @option options [Boolean] :show_top_level
  # @return [String] HTML <tr> elements
  #
  def resources_as_tree_rows(resources, options = {})
    resources = [] unless resources
    html = ''
    resources.each_with_index do |row, row_index|
      levels = 0
      Resource::MAX_TREE_LEVELS.times do |i|
        if row["lv#{i}_id"]
          levels += 1
        else
          break
        end
      end

      if row_index == 0
        start = options[:show_top_level] ? 0 : 1
      else
        start = levels - 1
      end

      (start..(levels - 1)).each do |level|
        # N.B. We aren't loading this from the database because it would be
        # too slow. Be careful with it.
        resource = Resource.new(id: row["lv#{level}_id"],
                                name: row["lv#{level}_name"],
                                assessment_complete: row["lv#{level}_assessment_complete"],
                                resource_type: row["lv#{level}_resource_type"])

        html += '<tr>'
        # column 1
        if options[:show_checkboxes]
          html += '<td>'
          html += "<input type=\"checkbox\" name=\"resources[]\" value=\"#{resource.id}\">"
          html += '</td>'
        end

        # column 2
        html += "<td class=\"depth-#{level}\">"
        if level > 0
          html += '&#8627; '
        end
        html += entity_icon(resource)
        html += link_to(truncate(resource.name, length: 150),
                        resource_path(resource.id))
        html += '</td>'

        # column 3
        html += '<td>'
        html += '&check;' if resource.assessment_complete
        html += '</td>'

        html += '</tr>'
      end
    end
    raw(html)
  end

  def score_formula
    html = '<span class="label label-primary">ASSESSMENT &times; 0.5</span> + '\
    '<span class="label label-primary">FORMAT &times; 0.4</span> + '\
    '<span class="label label-primary">LOCATION &times; 0.05</span> + '\
    '<span class="label label-primary">TEMPERATURE &times; 0.025</span> + '\
    '<span class="label label-primary">RELATIVE HUMIDITY &times; 0.025</span>'
    raw(html)
  end

  def score_help(resource)
    assessment_score = (resource.assessment_score * 100).round(1)
    format_score = (resource.effective_format_score * 100).round(1)
    location_score = (resource.location.assessment_score * 100).round(1)
    temp_score = (resource.effective_temperature_score * 100).round(1)
    humidity_score = (resource.effective_humidity_score * 100).round(1)

    text = '<p>The following formula is used to calculate a resource\'s '\
    'assessment score:</p>'\
    '<p>' + score_formula + '</p>'\
    '<ul>'

    if @resource.assessment_percent_complete < 1
      text += "<li>This resource's assessment is not yet complete, which "\
      "heavily weighs down its score.</li>"
    else
      text += "<li>This resource's assessment score is "\
      "<strong>#{assessment_score}</strong>.</li>" # TODO: "this is good" etc.
    end

    if resource.format
      text += "<li>Its format score is <strong>#{format_score}</strong>.</li>" # TODO: "this is good" or "consider migrating..." etc.
    else
      text += "<li>It does not yet have a format specified, which heavily "\
      "weighs down its score.</li>"
    end

    if resource.location.assessment_question_responses.length < 1
      text += "<li>Its location has not yet been assessed, which weighs down "\
      "its score.</li>"
    else
      text += "<li>Its location score is "\
      "<strong>#{location_score}</strong>.</li>" # TODO: "this is good" or "consider moving" etc.
    end

    text += "<li>Its temperature score is <strong>#{temp_score}</strong>.</li>"

    text += "<li>Its relative humidity score is "\
    "<strong>#{humidity_score}</strong>.</li>"

    text + '</ul>'
  end

  private

  def add_option_for_collection(collection, options, level)
    options << [raw(('&nbsp;&nbsp;&nbsp;&nbsp;' * level) +
                        (level > 0 ? raw('&#8627; ') : '') + collection.name),
                collection.id]
    collection.children.where(resource_type: Resource::Type::COLLECTION).each do |child|
      add_option_for_collection(child, options, level + 1)
    end
  end

end
