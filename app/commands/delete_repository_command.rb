class DeleteRepositoryCommand < Command

  def initialize(repository, doing_user, remote_ip)
    @repository = repository
    @doing_user = doing_user
    @address = remote_ip
  end

  def execute
    begin
      @repository.destroy!
    rescue ActiveRecord::DeleteRestrictionError => e
      raise e # this should never happen
    rescue => e
      raise "Failed to delete repository \"#{@repository.name}\": #{e.message}"
    end
  end

  def object
    @repository
  end

end
