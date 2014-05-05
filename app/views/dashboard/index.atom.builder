# Can't use AtomFeedHelper because it requires an entity with a "show" route.

# Eliminate whitespace
#xml = Builder::XmlMarkup.new

xml.instruct!
xml.feed(
    'xmlns' => 'http://www.w3.org/2005/Atom',
) {
  xml.title('My PSAP Dashboard')
  xml.link('href' => events_url)
  if @events.any?
    xml.updated(@events[0][:timestamp].iso8601)
  end
  xml.author {
    xml.name('Preservation Self-Assessment Program (PSAP)')
    xml.email('') # TODO: PSAP email address
    xml.uri(root_url)
  }
  xml.generator('uri' => root_url) {
    xml.text!('Preservation Self-Assessment Program (PSAP)')
  }
  xml.id("tag:#{request.host}:#{request.fullpath}")

  @events.each do |event|
    xml.entry {
      xml.title(event[:description])
      xml.author {
        xml.name(event[:user].username)
        xml.email(event[:user].email)
        xml.uri(user_url(event[:user]))
      }
      xml.link('href' => dashboard_url, 'rel' => 'via')
      xml.id(event[:id])
      xml.updated(event[:timestamp].iso8601)
      xml.summary(event[:summary])
    }
  end
}
