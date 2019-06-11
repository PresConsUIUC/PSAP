##
# Helper class for converting times and durations.
#
class TimeUtils

  ##
  # Estimates completion time based on a progress percentage.
  #
  # @param start_time [Time]
  # @param percent [Float]
  # @return [Time]
  #
  def self.eta(start_time, percent)
    if percent == 0
      1.year.from_now
    else
      start = start_time.utc
      now = Time.now.utc
      Time.at(start + ((now - start) / percent))
    end
  end

end