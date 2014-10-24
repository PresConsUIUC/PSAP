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
            resource = Resource.from_ead(io.read, @user.id)
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

end
