require 'rexml/document'

class ImportArchivesspaceEadCommand < Command

  def initialize(files, location, parent_resource, user, remote_ip)
    @files = files
    @location = location
    @parent_resource = parent_resource
    @user = user
    @remote_ip = remote_ip
    @resources = []
  end

  def execute
    begin
      ActiveRecord::Base.transaction do
        @files.each do |io|
          if File.extname(io.original_filename) == '.xml'
            attrs = resource_attributes_from_ead(io.read, @user.id)
            resource = Resource.new(attrs)
            resource.location = @location
            resource.parent = @parent_resource
            resource.save!
            @resources << resource
          end
        end
      end
    rescue => e
      Event.create(
          description: "Failed to import ArchivesSpace resources: #{e.message}",
          user: @user, address: @remote_ip, event_level: EventLevel::ERROR)
      raise e
    else
      @resources.each do |resource|
        resource.events << Event.create(
          description: "Imported resource \"#{resource.name}\" from ArchivesSpace",
          user: @user, address: @remote_ip)
      end
    end
  end

  def object
    @resources
  end

  private

  def resource_attributes_from_ead(ead, user_id)
    doc = REXML::Document.new(ead)

    begin
      User.find(user_id)
    rescue ActiveRecord::RecordNotFound => e
      raise 'Invalid user ID'
    end

    attrs = {}

    doc.elements.each('//archdesc/did/abstract[1]') do |element|
      attrs[:description] = element.text.strip
    end

    attrs[:format_id] = nil # TODO: format

    doc.elements.each('//archdesc/did/unitid[1]') do |element|
      attrs[:local_identifier] = element.text.strip
    end

    doc.elements.each('//archdesc/did/unittitle[1]') do |element|
      attrs[:name] = element.text.strip
    end

    attrs[:resource_notes] = [] # TODO: notes

    doc.elements.each('//archdesc') do |type|
      case type.attribute('level').value.strip
        when 'collection'
          attrs[:resource_type] = ResourceType::COLLECTION
        when 'item'
          attrs[:resource_type] = ResourceType::ITEM
      end
    end

    attrs[:user_id] = user_id

    # creators
    attrs[:creators_attributes] = []
    doc.elements.each('//archdesc/did/origination') do |element|
      if element.attribute('label').value == 'creator'
        attrs[:creators_attributes] << {
            name: element.elements['persname'].text.strip }
      end
    end

    # extents
    attrs[:extents_attributes] = []
    doc.elements.each('//archdesc/did/physdesc/extent') do |extent|
      attrs[:extents_attributes] << { name: extent.text.strip }
    end

    # dates
    attrs[:resource_dates_attributes] = []
    doc.elements.each('//archdesc/did/unitdate') do |element|
      date_struct = {}

      case element.attribute('type').value
        when 'inclusive'
          date_struct[:date_type] = DateType::INCLUSIVE
        when 'bulk'
          date_struct[:date_type] = DateType::BULK
        when 'span'
          date_struct[:date_type] = DateType::SPAN
        when 'single'
          date_struct[:date_type] = DateType::SINGLE
      end

      date_text = element.attribute('normal').value
      date_parts = date_text.split('/')

      case date_struct[:date_type]
        when DateType::SINGLE
          date_struct.merge!(eadDateToYmdHash(date_parts[0]))
        else
          if date_parts.length > 1
            begin_parts = eadDateToYmdHash(date_parts[0])
            end_parts = eadDateToYmdHash(date_parts[1])
            date_struct[:begin_year] = begin_parts[:year] if begin_parts[:year]
            date_struct[:begin_month] = begin_parts[:month] if begin_parts[:month]
            date_struct[:begin_day] = begin_parts[:day] if begin_parts[:day]
            date_struct[:end_year] = end_parts[:year] if end_parts[:year]
            date_struct[:end_month] = end_parts[:month] if end_parts[:month]
            date_struct[:end_day] = end_parts[:day] if end_parts[:day]
          else
            parts = eadDateToYmdHash(date_parts[0])
            date_struct[:begin_year] = parts[:year] if parts[:year]
            date_struct[:begin_month] = parts[:month] if parts[:month]
            date_struct[:begin_day] = parts[:day] if parts[:day]
            date_struct[:end_year] = parts[:year] if parts[:year]
            date_struct[:end_month] = parts[:month] if parts[:month]
            date_struct[:end_day] = parts[:day] if parts[:day]
          end
      end

      attrs[:resource_dates_attributes] << date_struct
    end

    # subjects
    attrs[:subjects_attributes] = []
    doc.elements.each('//archdesc/controlaccess/*') do |subject|
      attrs[:subjects_attributes] << { name: subject.text.strip }
    end

    attrs
  end

  private

  def eadDateToYmdHash(date)
    date = date.split('-')
    parts = {}
    parts[:day] = date[2].to_i if date.length > 2
    parts[:month] = date[1].to_i if date.length > 1
    parts[:year] = date[0].to_i
    parts
  end

end
