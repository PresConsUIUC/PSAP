class SignInFailure < RuntimeError

  def public_message
    @public_message
  end

  def public_message=(msg)
    @public_message = msg
  end

end

class SignInCommand < Command

  def initialize(username, password, remote_ip)
    @username = username.chomp
    @password = password
    @remote_ip = remote_ip
    @user = nil
  end

  def execute
    begin
      public_message = nil
      log_message = nil

      unless @username.empty?
        if @password
          @user = User.find_by(username: @username.downcase,
                              enabled: true,
                              confirmed: true)
          if @user && @user.authenticate(@password)
            Event.create(description: "User #{@user.username} signed in",
                         user: @user, address: @remote_ip)
            @user.last_signin = Time.now
            @user.save!
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
      Event.create(description: "#{e}", user: @user, address: @remote_ip,
                   event_level: EventLevel::NOTICE)
      raise "#{e.public_message}"
    rescue => e
      Event.create(description: "#{e}", user: @user, address: @remote_ip,
                   event_level: EventLevel::NOTICE)
      raise e
    end
  end

  def object
    @user
  end

end
