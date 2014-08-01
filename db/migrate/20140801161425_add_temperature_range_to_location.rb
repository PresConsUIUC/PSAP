class AddTemperatureRangeToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :temperature_range_id, :integer
    change_column_null :temperature_ranges, :format_id, true
  end
end
