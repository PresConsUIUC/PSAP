class AddFormatRefToTemperatureRanges < ActiveRecord::Migration
  def change
    add_reference :temperature_ranges, :format, index: true
  end
end
