class CreateTemperatureRanges < ActiveRecord::Migration
  def change
    create_table :temperature_ranges do |t|
      t.decimal :min_temp_f, precision: 3, scale: 0
      t.decimal :max_temp_f, precision: 3, scale: 0
      t.float :score
    end
  end
end
