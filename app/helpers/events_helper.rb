module EventsHelper

  def level_buttons(current_level)
    levels = EventLevel::all.sort do |a, b|
      b <=> a
    end

    links = ''
    levels.each do |level|
      cssClass = 'btn btn-sm level_button '
      cssClass.concat (current_level.to_i == level) ? 'btn-info' : 'btn-default'
      links << link_to(EventLevel::name_for_level(level), "?level=#{level}",
                  class: cssClass, remote: true, 'data-level' => level)
    end
    links
  end

end
