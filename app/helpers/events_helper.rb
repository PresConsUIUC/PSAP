module EventsHelper

  def bootstrap_class_for_event_level(level)
    case level
      when EventLevel::DEBUG
        'label label-default'
      when EventLevel::INFO
        'label label-default'
      when EventLevel::NOTICE
        'label label-info'
      when EventLevel::WARNING
        'label label-warning'
      when EventLevel::ERROR
        'label label-warning'
      when EventLevel::CRITICAL
        'label label-danger'
      when EventLevel::ALERT
        'label label-danger'
      when EventLevel::EMERGENCY
        'label label-danger'
      else
        flash_type.to_s
    end
  end

  def event_level_buttons(current_level, params)
    levels = EventLevel::all.sort{ |a, b| b <=> a }
    links = []
    levels.each do |level|
      params = params.dup
      link_params = params.merge(level: level).except(:page)
      events = Event.matching_params(link_params)
      level_count = events.where('event_level = ?', level).count

      css_class = 'btn btn-sm level_button '
      css_class.concat (current_level.to_i == level) ?
                          'btn-info active' : 'btn-default'

      links << link_to(raw("#{EventLevel::name_for_level(level)}<span class=\"badge pull-right\">#{level_count}</span>"),
                       link_params, class: css_class, remote: true,
                       'data-level' => level)
    end
    links.join
  end

  def link_to_event_entity(event)
    string = entity = ''
    case event.associated_entity_class.to_s
      when 'Assessment'
        entity = event.assessments.first
        string = entity.name
      when 'AssessmentQuestion'
        entity = event.assessment_questions.first
        string = entity.name
      when 'AssessmentSection'
        entity = event.assessment_sections.first
        string = entity.name
      when 'Format'
        entity = event.formats.first
        string = entity.name
      when 'Institution'
        entity = event.institutions.first
        string = entity.name
      when 'Location'
        entity = event.locations.first
        string = entity.name
      when 'Repository'
        entity = event.repositories.first
        string = entity.name
      when 'Resource'
        entity = event.resources.first
        string = entity.name
      when 'User'
        entity = event.users.first
        string = entity.full_name

    end
    url = url_for(entity) rescue nil
    if url
      link = link_to(url) do
        raw(entity_icon(event.associated_entity_class)) + ' ' + string
      end
    end
    raw(link)
  end

end
