# Can't use AtomFeedHelper because it requires a "show" route on events.

# Eliminates whitespace
xml = Builder::XmlMarkup.new

xml.instruct!
xml.feed(
    'xmlns' => 'http://www.w3.org/2005/Atom',
) {
  if params[:level]
    xml.title("PSAP #{EventLevel.name_for_level(params[:level].to_i)} Events")
  else
    xml.title('All PSAP Events')
  end
  xml.link('href' => events_url)
  if @events.any?
    xml.updated(@events[0].created_at)
  end
  xml.author {
    xml.name('Preservation Self-Assessment Program (PSAP)')
    xml.email('') # TODO: PSAP email address
    xml.uri(root_url)
  }
  xml.generator('uri' => root_url) {
    xml.text!('Preservation Self-Assessment Program (PSAP)')
  }
  xml.id("tag:#{request.host}:#{request.fullpath.split('.')}")

  @events.each do |event|
    xml.entry {
      xml.title(event.description)
      if event.user
        xml.author {
          xml.name(event.user.username)
          xml.email(event.user.email)
          xml.uri(user_url(event.user))
        }
      end
      xml.link('href' => events_url, 'rel' => 'via')
      xml.id("tag:#{request.host}:#{request.fullpath.split('.')}:#{event.id}")
      xml.updated(event.created_at)
      xml.summary(event.description)
    }
  end
}
