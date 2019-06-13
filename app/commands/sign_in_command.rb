class SignInFailure < RuntimeError

  attr_accessor :public_message

end

class SignInCommand < Command

  def initialize(username, password, remote_ip)
    @username = username.chomp
    @password = password
    @remote_ip = remote_ip
    @user = nil
    @first_signin = false
  end

  def execute
    begin
      public_message = nil
      log_message = nil

      if @username.present?
        if @password
          @user = User.find_by_username(@username)
          if @user
            if @user.enabled and @user.confirmed and
                @user.authenticate(@password)
              @first_signin = @user.last_signin.blank?
              @user.last_signin = Time.now
              @user.save!
            elsif !@user.confirmed
              @user = nil # could be an impostor
              public_message = 'Your account has not yet been confirmed. '\
              'Please check your mailbox for an email from the PSAP and '\
              'click the confirmation link contained within. '
              log_message = "Sign-in failed for #{@username}: account not "\
              "confirmed."
            elsif !@user.enabled and !@user.last_signin
              @user = nil # could be an impostor
              public_message = 'Your account has been confirmed, but it has not '\
              'yet been enabled by PSAP staff. We try to do this as quickly as '\
              'possible, but if you have been waiting a while, please feel free '\
              'to contact us.'
              log_message = "Sign-in failed for #{@username}: account not "\
              "enabled."
            else
              @user = nil # could be an impostor
              public_message = 'Sign-in failed.'
              log_message = "Sign-in failed for #{@username}: invalid username "\
              "or password."
            end
          else
            public_message = 'Sign-in failed.'
            log_message = "Sign-in failed for #{@username}: invalid username "\
            "or password."
          end
        end
      else
        public_message = 'Sign-in failed.'
        log_message = 'Sign-in failed: no username provided.'
      end

      if public_message
        ex = SignInFailure.new(log_message)
        ex.public_message = public_message
        raise ex
      end
    rescue SignInFailure => e
      raise "#{e.public_message}"
    end
  end

  def first_signin?
    @first_signin
  end

  def object
    @user
  end

end
