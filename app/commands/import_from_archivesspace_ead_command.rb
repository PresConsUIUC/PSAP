require 'net/http'
require 'uri'
require 'rexml/document'

class ImportFromArchivesspaceEadCommand < Command

  def initialize(user, remote_host, remote_port, remote_username,
      remote_password, remote_resource_id, user_ip)
    @user = user
    @remote_host = remote_host
    @remote_port = remote_port
    @remote_username = remote_username
    @remote_password = remote_password
    @remote_resource_id = remote_resource_id
    @user_ip = user_ip
    @resource = nil
  end

  def execute
    begin
      # Sandbox server (username/password: admin/admin):
      # POST http://sandbox.archivesspace.org/login
      # GET http://sandbox.archivesspace.org/resources/45/download_ead
      remote_host = @remote_host.chomp.tr('/')
      session_cookie = get_session_cookie(remote_host)
      ead = get_ead(remote_host, session_cookie)
      attributes = resource_attributes_from_ead(ead)
      @resource = Resource.create!(attributes)
    rescue => e
      Event.create(description: "Failed to import resource \"#{}\" from "\
      "ArchivesSpace at #{@remote_host}: #{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE)
      raise e
    else
      Event.create(description: "Imported resource \"#{}\" from ArchivesSpace "\
        "at #{@remote_host}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::SUCCESS)
    end
  end

  def object
    @resource
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
