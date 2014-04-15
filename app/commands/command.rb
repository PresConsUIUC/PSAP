# Abstract command class from which all commands should inherit.
class Command

  # Executes the command, raising an exception if anything goes wrong.
  def execute
    raise NotImplementedError, 'Command must override execute method'
  end

  # Returns the object, if any, on which the command will or did act.
  def object
    nil
  end

end
