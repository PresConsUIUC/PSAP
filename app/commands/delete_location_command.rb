class DeleteLocationCommand < Command

  def initialize(location, doing_user, remote_ip)
    @location = location
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @location.destroy!
    rescue ActiveRecord::DeleteRestrictionError => e
      raise e # this should never happen
    rescue => e
      raise "Failed to delete location: #{e.message}"
    end
  end

  def object
    @location
  end

end
