class DeleteUserCommand < Command

  def initialize(user, doing_user, remote_ip)
    @user = user
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      raise 'Insufficient privileges' unless @doing_user.is_admin?
      @user.destroy!
    rescue ActiveRecord::DeleteRestrictionError => e
      raise e # should never happen
    rescue => e
      if @user == @doing_user
        raise "Failed to delete your account: #{e.message}"
      else
        raise "Failed to delete user #{@user.username}: #{e.message}"
      end
    end
  end

  def object
    @user
  end

end
