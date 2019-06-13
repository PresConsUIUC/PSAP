class ApproveUserInstitutionCommand < Command

  def initialize(user, doing_user, remote_ip)
    @user = user
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      raise "#{@doing_user.username} has insufficient privileges to "\
        "approve user institution change requests." unless @doing_user.is_admin?

      raise "#{@user} has no desired institution." unless
          @user.desired_institution

      ActiveRecord::Base.transaction do
        @user.institution = @user.desired_institution
        @user.desired_institution = nil
        @user.save!
        UserMailer.institution_change_approved_email(@user).deliver_now
      end
    rescue => e
      raise "Failed to approve the institution of user #{@user.username}: "\
      "#{e.message}"
    end
  end

  def object
    @user
  end

end
