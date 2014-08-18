# Abstract command class in the command pattern, from which all commands
# should inherit.
class Command

  # Executes the command, checking all necessary preconditions and raising an
  # error if anything goes wrong. Error messages should be suitable for
  # public consumption. Success/failure should be written to the event log.
  def execute
    raise NotImplementedError, 'Command must override execute method'
  end

  # Returns the object, if any, on which the command will or did act. This
  # method exists to establish convention, but is optional. Some commands may
  # operate on <> 1 object, in which case they might want to define their own
  # getter(s) instead of this.
  def object
    nil
  end

end
