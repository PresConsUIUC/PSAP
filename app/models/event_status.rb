class EventStatus

  SUCCESS = 0
  FAILURE = 1

  def self.all
    return (0..1).to_a
  end

end
