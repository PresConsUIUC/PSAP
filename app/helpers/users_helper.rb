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

end
