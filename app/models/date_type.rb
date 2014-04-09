class DateType

  SINGLE = 0
  BULK = 1
  INCLUSIVE = 2
  SPAN = 2 # span == inclusive

  def self.all
    return [0, 1, 2]
  end

end
