module EventsHelper

  def bootstrap_class_for_event_level level
    case level
      when EventLevel::DEBUG
        'text-muted'
      when EventLevel::INFO
        'text-info'
      when EventLevel::NOTICE
        'text-info'
      when EventLevel::WARNING
        'text-warning'
      when EventLevel::ERROR
        'text-danger'
      when EventLevel::CRITICAL
        'text-danger'
      when EventLevel::ALERT
        'text-danger'
      when EventLevel::EMERGENCY
        'text-danger'
      else
        flash_type.to_s
    end
  end

  def level_buttons(current_level)
    levels = EventLevel::all.sort do |a, b|
      b <=> a
    end

    links = ''
    levels.each do |level|
      cssClass = 'btn btn-sm level_button '
      cssClass.concat (current_level.to_i == level) ? 'btn-info active' : 'btn-default'
      links << link_to(EventLevel::name_for_level(level), "?level=#{level}",
                  class: cssClass, remote: true, 'data-level' => level)
    end
    links
  end

end
