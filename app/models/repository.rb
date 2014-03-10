class Repository < ActiveRecord::Base
  belongs_to :institution, inverse_of: :repositories
  has_many :locations, inverse_of: :repository

  after_initialize :setup, if: :new_record?

  def setup
    # associate a default location
    if self.locations.empty?
      @location = Location.new(name: 'Default Location', is_default: true)
      self.locations << @location
    end
  end

  def default_location
    @locations.each do |location|
      if location.is_default
        return location
      end
    end
  end

end
