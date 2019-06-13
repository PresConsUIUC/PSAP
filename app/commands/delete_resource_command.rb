class DeleteResourceCommand < Command

  def initialize(resource, doing_user, remote_ip)
    @resource = resource
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @resource.destroy!
    rescue ActiveRecord::DeleteRestrictionError => e
      raise e # this should never happen
    rescue => e
      raise "Failed to delete resource \"#{@resource.name}\": "\
      "#{e.message}"
    end
  end

  def object
    @resource
  end

end
