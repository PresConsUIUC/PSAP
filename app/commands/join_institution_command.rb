class JoinInstitutionCommand < Command

  def initialize(user, institution, doing_user, remote_ip)
    @user = user
    @institution = institution
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      # non-admin users are not allowed to update other users
      if !@doing_user.is_admin? and @doing_user != @user
        raise 'Insufficient privileges'
      end

      return if @institution == @user.institution # nothing to do

      ActiveRecord::Base.transaction do
        if @doing_user
          if @doing_user.is_admin? # admins can change institutions with no review
            @user.institution = @institution
            @user.save!
          else # non-admin institution changes require review
            @user.desired_institution = @institution
            @user.save!
            AdminMailer.institution_change_review_request_email(@user).deliver_now
          end
        end
        @institution.reload
      end
    rescue ActiveRecord::RecordInvalid
      if @user == @doing_user
        raise ValidationError,
              "Failed to change your institution: "\
              "#{@user.errors.full_messages[0]}"
      else
        raise ValidationError,
              "Failed to change institution of user #{@user.username}: "\
              "#{@user.errors.full_messages[0]}"
      end
    rescue => e
      if @user == @doing_user
        raise "Failed to change your institution: #{e.message}"
      else
        raise "Failed to change institution of user #{@user.username}: "\
        "#{e.message}"
      end
    end
  end

  def object
    @institution
  end

end
