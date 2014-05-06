module EventsHelper

  def bootstrap_class_for_event_level level
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

  def level_buttons(current_level) # TODO: badge counts on these
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
