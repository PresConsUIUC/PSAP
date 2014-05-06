require 'net/http'
require 'uri'
require 'rexml/document'

class ImportFromArchivesspaceEadCommand < Command

  def initialize(resource_import_params, user, user_ip)
    @user = user
    @user_ip = user_ip
    @archivesspace_import = ArchivesspaceImport.new(resource_import_params)
  end

  def execute
    begin
      # Sandbox server (username/password: admin/admin):
      # POST http://sandbox.archivesspace.org/login
      # GET http://sandbox.archivesspace.org/resources/45/download_ead
      remote_host = @archivesspace_import.host.chomp.tr('/')
      session_cookie = get_session_cookie(remote_host)
      ead = get_ead(remote_host, session_cookie)
      attributes = resource_attributes_from_ead(ead)
      #@resource = Resource.create!(attributes)
    rescue => e
      Event.create(description: "Failed to import resource from "\
      "ArchivesSpace at #{@@archivesspace_import.host}: #{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE)
      raise e
    else
      Event.create(description: "Imported resource \"#{@resource.name}\" "\
      "from ArchivesSpace at #{@archivesspace_import.host}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::SUCCESS)
    end
  end

  def object
    @archivesspace_import
  end

  private

  def get_session_cookie(remote_host)
    login_uri = URI.parse("#{remote_host}/login")
    request = Net::HTTP::Post.new(login_uri.host, @remote_port)
    request.set_form_data({ username: @remote_username,
                            password: @remote_password })
    response = http.request(request)

    unless response.code.to_i == 200
      message = "Failed to sign into ArchivesSpace. HTTP response: "\
        "#{response.code} #{response.message}"
      raise message
    end

    response.response['set-cookie'].split('; ')[0]
  end

  def get_ead(remote_host, session_cookie)
    ead_uri = URI.parse(
        "#{remote_host}/resources/#{@remote_resource_id}/download_ead")
    request = Net::HTTP::Get.new(ead_uri.host, @remote_port)
    request.add_field('Cookie', session_cookie)
    response = http.request(request)

    unless response.code.to_i == 200
      message = "Failed to retrieve EAD. HTTP response: "\
        "#{response.code} #{response.message}"
      raise message
    end

    response.body
  end

  def resource_attributes_from_ead(ead)
    doc = REXML::Document.new(ead)
    resource_attrs = {}
    doc.elements['eadheader']

    resource_attrs
  end

end
