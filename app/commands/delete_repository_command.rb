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
      Event.create(description: "Attempted to delete repository "\
      "\"#{@repository.name},\" but failed: "\
      "#{@repository.errors.full_messages[0]}",
                   user: @doing_user, address: @address,
                   event_level: EventLevel::ERROR)
      raise "Failed to delete repository \"#{@repository.name}\": "\
      "#{@location.errors.full_messages[0]}"
    else
      Event.create(description: "Deleted repository \"#{@repository.name}\" "\
      "from institution \"#{@repository.institution.name}\"",
                   user: @doing_user, address: @address)
    end
  end

  def object
    @repository
  end

end
