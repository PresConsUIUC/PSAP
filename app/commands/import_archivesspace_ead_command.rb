require 'rexml/document'

class ImportArchivesspaceEadCommand < Command

  def initialize(files, parent_resource, location, user, remote_ip)
    @files = files
    @parent_resource = parent_resource
    @location = location
    @user = user
    @remote_ip = remote_ip
    @resources = []
  end

  def execute
    ActiveRecord::Base.transaction do
      @files.each do |io|
        if (io.respond_to?('original_filename') and
            File.extname(io.original_filename) == '.xml') or
            !io.respond_to?('original_filename')
          resource = Resource.from_ead(io.read, @user)
          resource.location = @location
          resource.parent = @parent_resource
          resource.save!
          @resources << resource
        end
      end
    end
  end

  def object
    @resources
  end

end
