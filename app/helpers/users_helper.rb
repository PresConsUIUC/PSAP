module UsersHelper

  def confirmation_status(user)
    bootstrap_class = user.confirmed ? 'label-success' : 'label-danger'
    confirmed = user.confirmed ? 'Confirmed' : 'Unconfirmed'
    raw("<span class=\"label #{bootstrap_class}\">#{confirmed}</span>")
  end

  def enabled_status(user)
    bootstrap_class = user.enabled ? 'label-success' : 'label-danger'
    enabled = user.enabled ? 'Enabled' : 'Disabled'
    raw("<span class=\"label #{bootstrap_class}\">#{enabled}</span>")
  end

  # Returns the Gravatar (http://gravatar.com/) for the given user.
  def gravatar_for(user, options = { size: 50 })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.full_name, class: 'gravatar')
  end

  def users_requiring_action_panel
    to_enable = User.where(confirmed: true).where(enabled: false).
        where(last_signin: nil)
    to_change_institution = User.where(confirmed: true).
        where('desired_institution_id IS NOT NULL')

    html = ''
    if to_enable.any? or to_change_institution.any?
      html += '<div class="alert alert-warning psap-users-requiring-action">'
      if to_enable.any?
        html += '<h4>Users requesting to be enabled:</h4>'\
          '<ul>'
        to_enable.each do |user|
          html += "<li>#{entity_icon(user)} #{link_to(user.full_name, user)}</li>"\
        end
        html += '</ul>'\
      end
      if to_change_institution.any?
        html += '<h4>Users requesting to join or change institutions:</h4>'\
          '<ul>'
        to_change_institution.each do |user|
          html += "<li>#{entity_icon(user)} #{link_to(user.full_name, user)}</li>"\
        end
        html += '</ul>'\
      end
      html += '</div>'
    end
    raw(html)
  end

end
