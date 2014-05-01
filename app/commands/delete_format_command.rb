class DeleteFormatCommand < Command

  def initialize(format, user, remote_ip)
    @format = format
    @user = user
    @remote_ip = remote_ip
  end

  def execute
    @format.destroy!
    Event.create(description: "Deleted format \"#{@format.name}\"",
                 user: @user, address: @remote_ip,
                 event_status: EventStatus::SUCCESS)
  end

  def object
    @format
  end

end
