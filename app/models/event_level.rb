class EventLevel

  # These are based on the levels used by syslog.
  EMERGENCY = 0
  ALERT = 1
  CRITICAL = 2
  ERROR = 3
  WARNING = 4
  NOTICE = 5
  INFO = 6
  DEBUG = 7

  def self.all
    (0..7).to_a
  end

  def self.name_for_level(level)
    case level
      when EventLevel::EMERGENCY
        'Emergency'
      when EventLevel::ALERT
        'Alert'
      when EventLevel::CRITICAL
        'Critical'
      when EventLevel::ERROR
        'Error'
      when EventLevel::WARNING
        'Warning'
      when EventLevel::NOTICE
        'Notice'
      when EventLevel::INFO
        'Info'
      when EventLevel::DEBUG
        'Debug'
    end
  end

end
