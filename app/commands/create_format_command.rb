class CreateFormatCommand < Command

  def initialize(format_params, user, remote_ip)
    @format_params = format_params
    @user = user
    @remote_ip = remote_ip
    @format = Format.new(format_params)
  end

  def execute
    @format.save!
    Event.create(description: "Created format \"#{@format.name}\"",
                 user: @user, address: @remote_ip)
  end

  def object
    @format
  end

end
