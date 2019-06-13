class CloneResourceCommand < Command

  def initialize(resource, omit_assessment_data, doing_user, remote_ip)
    @resource = resource
    @doing_user = doing_user
    @remote_ip = remote_ip
    @cloned_resource = @resource.dup(omit_assessment_data)
  end

  def execute
    begin
      @cloned_resource.save!
    rescue => e
      raise "Failed to clone resource #{@resource.name}: #{e.message}"
    end
  end

  def object
    @cloned_resource
  end

end
