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
  if @resource.resource_type == Resource::Type::COLLECTION
    xml.tag!('dc:type', 'collection')
  elsif @resource.format
    xml.tag!('dc:type',
             FormatClass::name_for_class(@resource.format.format_class))
  end
  xml.tag!('dc:language', @resource.language ?
      @resource.language.iso639_2_code :
      @resource.location.repository.institution.language.iso639_2_code)
  @resource.extents.each do |extent|
    xml.tag!('dc:format', extent.name)
  end
  xml.tag!('dc:format', @resource.format.name) if @resource.format
  xml.tag!('dc:format', @resource.format_ink_media_type.name) if @resource.format_ink_media_type
  xml.tag!('dc:format', @resource.format_support_type.name) if @resource.format_support_type
  @resource.subjects.each do |subject|
    xml.tag!('dc:subject', subject.name)
  end
  xml.tag!('dc:description', @resource.description) if @resource.description
  @resource.resource_notes.each do |note|
    xml.tag!('dc:description', note.value)
  end
  xml.tag!('dc:rights', @resource.rights) if @resource.rights
  if @resource.parent
    xml.tag!('dc:relation', "isPartOf #{@resource.parent.name} (#{@resource.parent.local_identifier})")
  end
  if @resource.resource_type == Resource::Type::COLLECTION
    @resource.children.each do |child|
      xml.tag!('dc:relation', "hasPart #{child.name} (#{child.local_identifier})")
    end
  end
end
