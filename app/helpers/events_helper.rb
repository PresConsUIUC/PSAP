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

  def level_buttons(current_level, params)
    levels = EventLevel::all.sort do |a, b|
      b <=> a
    end

    links = []
    levels.each do |level|
      params = params.dup
      link_params = params.merge({ level: level })
      events = Event.matching_params(link_params)
      level_count = events.where('event_level = ?', level).count

      cssClass = 'btn btn-sm level_button '
      cssClass.concat (current_level.to_i == level) ?
                          'btn-info active' : 'btn-default'

      links << link_to(raw("#{EventLevel::name_for_level(level)}<span class=\"badge pull-right\">#{level_count}</span>"),
                       link_params, class: cssClass, remote: true,
                       'data-level' => level)
    end
    links.join
  end

  def link_to_event_entity(event)
    if event.assessments.any?
      return link_to event.assessments[0].name, event.assessments[0]
    elsif event.assessment_questions.any?
      return link_to event.assessment_questions[0].name,
                     event.assessment_questions[0]
    elsif event.assessment_sections.any?
      return link_to event.assessment_sections[0].name,
                     event.assessment_sections[0]
    elsif event.formats.any?
      return link_to event.formats[0].name, event.formats[0]
    elsif event.institutions.any?
      return link_to event.institutions[0].name,
                     event.institutions[0]
    elsif event.locations.any?
      return link_to event.locations[0].name,
                     event.locations[0]
    elsif event.repositories.any?
      return link_to event.repositories[0].name, event.repositories[0]
    elsif event.resources.any?
      return link_to event.resources[0].name,
                     event.resources[0]
    elsif event.users.any?
      return link_to event.users[0].full_name, event.users[0]
    end
    ''
  end

end
