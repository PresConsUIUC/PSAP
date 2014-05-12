# Eliminates whitespace
# xml = Builder::XmlMarkup.new

xml.instruct!

xml.tag!('oai_dc:dc',
         { 'xmlns:oai_dc' => 'http://www.openarchives.org/OAI/2.0/oai_dc/',
           'xmlns:dc' => 'http://purl.org/dc/elements/1.1/',
           'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
           'xsi:schemaLocation' => 'http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd'
         }) do
  xml.tag!('dc:title', @resource.name)
  xml.tag!('dc:identifier', @resource.local_identifier) if @resource.local_identifier
  @resource.creators.each do |creator|
    xml.tag!('dc:creator', creator.name)
  end
  @resource.resource_dates.each do |date|
    xml.tag!('dc:date', date.as_dublin_core_string)
  end
  xml.tag!('dc:type',
           @resource.resource_type == ResourceType::ITEM ? 'item' : 'collection')
  xml.tag!('dc:language',
           @resource.location.repository.institution.language.iso639_2_code)
  @resource.extents.each do |extent|
    xml.tag!('dc:format', extent.name)
  end
  @resource.subjects.each do |subject|
    xml.tag!('dc:subject', subject.name)
  end
  xml.tag!('dc:description', @resource.description) if @resource.description
  xml.tag!('dc:description', @resource.notes) if @resource.notes # TODO: support multiple notes
  xml.tag!('dc:rights', @resource.rights) if @resource.rights
  if @resource.parent
    xml.tag!('dc:relation', "isPartOf #{@resource.parent.name} (#{@resource.parent.local_identifier})")
  end
  if @resource.resource_type == ResourceType::COLLECTION
    @resource.children.each do |child|
      xml.tag!('dc:relation', "hasPart #{child.name} (#{child.local_identifier})")
    end
  end
end
