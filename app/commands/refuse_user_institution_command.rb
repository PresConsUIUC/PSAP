class RefuseUserInstitutionCommand < Command

  def initialize(user, doing_user, remote_ip)
    @user = user
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      raise "#{@doing_user.username} has insufficient privileges to "\
        "refuse user institution change requests." unless @doing_user.is_admin?

      raise "#{@user} has no desired institution." unless
          @user.desired_institution

      ActiveRecord::Base.transaction do
        @user.desired_institution = nil
        @user.save!
        UserMailer.institution_change_refused_email(@user).deliver_now
      end
    rescue => e
      raise "Failed to refuse the institution change request of user "\
      "#{@user.username}: #{e.message}"
    end
  end

  def object
    @user
  end

end
