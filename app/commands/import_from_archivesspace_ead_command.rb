require 'net/http'
require 'uri'
require 'rexml/document'

class ImportFromArchivesspaceEadCommand < Command

  def initialize(archivesspace_import_params, user, user_ip)
    @user = user
    @user_ip = user_ip
    @archivesspace_import = ArchivesspaceImport.new(archivesspace_import_params)
    @resource = nil
  end

  def execute
    begin
      # Sandbox server (username/password: admin/admin):
      # http://sandbox.archivesspace.org
      #
      # Website (used by this command):
      # POST http://sandbox.archivesspace.org/login
      # GET http://sandbox.archivesspace.org/resources/45/download_ead
      #
      # REST API (available, but not used by this command):
      # https://github.com/archivesspace/archivesspace/blob/master/ARCHITECTURE.md
      # http://archivesspace.github.io/archivesspace/doc/file.API.html
      # POST http;//sandbox.archivesspace.org/users/admin/login?password=login
      # GET http://sandbox.archivesspace.org/repositories/2/resource_descriptions/2.xml
      remote_host = @archivesspace_import.host.chomp('/')
      if remote_host[0..7] == 'https://'
        remote_host = 'https://' + remote_host.gsub('https://', '')
      else
        remote_host = 'http://' + remote_host.gsub('http://', '')
      end

      session_token = get_session_token(remote_host,
                                        @archivesspace_import.port,
                                        @archivesspace_import.username,
                                        @archivesspace_import.password)
      ead = get_ead(remote_host, @archivesspace_import.port,
                    @archivesspace_import.resource_id,
                    session_token)
      attributes = resource_attributes_from_ead(ead, @user.id)
      @resource = Resource.create!(attributes)
    rescue => e
      Event.create(description: "Failed to import resource from "\
      "ArchivesSpace at #{@archivesspace_import.host}: #{e.message}",
                   user: @user, address: @remote_ip,
                   event_level: EventLevel::ERROR)
      raise e
    else
      Event.create(description: "Imported resource \"#{@resource.name}\" "\
      "from ArchivesSpace at #{@archivesspace_import.host}",
                   user: @user, address: @remote_ip)
    end
  end

  def created_resource
    @resource
  end

  def object
    @archivesspace_import
  end

  def get_session_token(host, port, username, password)
    login_uri = URI.parse("#{host}/login")
    http = Net::HTTP.new(login_uri.host, port)
    request = Net::HTTP::Post.new(login_uri)
    request.set_form_data({ username: username, password: password })
    response = http.request(request)

    unless response.code.to_i == 200
      message = "Failed to sign into ArchivesSpace. HTTP response: "\
        "#{response.code} #{response.message}"
      raise message
    end

    response.response['set-cookie'].split('; ')[0]
  end

  def get_ead(host, port, resource_id, session_token)
    ead_uri = URI.parse("#{host}/resources/#{resource_id}/download_ead")
    http = Net::HTTP.new(ead_uri.host, port)
    request = Net::HTTP::Get.new(ead_uri)
    request['Cookie'] = session_token
    response = http.request(request)

    unless response.code.to_i == 200
      message = "Failed to retrieve EAD. HTTP response: "\
        "#{response.code} #{response.message}"
      raise message
    end

    response.body
  end

  def resource_attributes_from_ead(ead, user_id)
    doc = REXML::Document.new(ead)

    begin
      User.find(user_id)
    rescue ActiveRecord::RecordNotFound => e
      raise 'Invalid user ID'
    end

    attrs = {}

    attrs[:description] = nil

    attrs[:format_id] = nil

    doc.elements.each('//archdesc/did/unitid[1]') do |element|
      attrs[:local_identifier] = element.text.strip
    end

    attrs[:location_id] = nil

    doc.elements.each('//archdesc/did/unittitle[1]') do |element|
      attrs[:name] = element.text.strip
    end

    attrs[:notes] = nil

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
    doc.elements.each('//archdesc/did/unitdate[1]') do |element|
      struct = {}

      case element.attribute('type').value
        when 'inclusive'
          struct[:date_type] = DateType::INCLUSIVE
        when 'bulk'
          struct[:date_type] = DateType::BULK
        when 'span'
          struct[:date_type] = DateType::SPAN
        when 'single'
          struct[:date_type] = DateType::SINGLE
      end

      case struct[:date_type]
        when DateType::SINGLE
          parts = eadDateToYmdHash(element.text)
          struct[:year] = parts[:year]
          struct[:month] = parts[:month]
          struct[:day] = parts[:day]
        else
          range = element.text.split('-')
          if range.length > 1
            begin_parts = eadDateToYmdHash(range[0])
            end_parts = eadDateToYmdHash(range[1])
            struct[:begin_year] = begin_parts[:year] if begin_parts[:year]
            struct[:begin_month] = begin_parts[:month] if begin_parts[:month]
            struct[:begin_day] = begin_parts[:day] if begin_parts[:day]
            struct[:end_year] = end_parts[:year] if end_parts[:year]
            struct[:end_month] = end_parts[:month] if end_parts[:month]
            struct[:end_day] = end_parts[:day] if end_parts[:day]
          elsif range.length > 0
            parts = eadDateToYmdHash(range[0])
            struct[:begin_year] = parts[:year] if parts[:year]
            struct[:begin_month] = parts[:month] if parts[:month]
            struct[:begin_day] = parts[:day] if parts[:day]
            struct[:end_year] = parts[:year] if parts[:year]
            struct[:end_month] = parts[:month] if parts[:month]
            struct[:end_day] = parts[:day] if parts[:day]
          end
      end

      attrs[:resource_dates_attributes] << struct
    end

    # subjects
    attrs[:subjects_attributes] = []
    doc.elements.each('archdesc/did/physdesc/???').each do |subject|
    end

    # TODO: if a collection, import contents from archdesc/dsc element

    attrs
  end

  private

  def eadDateToYmdHash(date)
    date = date.split('/')
    parts = {}
    parts[:day] = date[2].to_i if date.length > 2
    parts[:month] = date[1].to_i if date.length > 1
    parts[:year] = date[0].to_i if date.length > 0
    parts
  end

end
