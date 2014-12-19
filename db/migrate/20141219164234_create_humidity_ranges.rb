class CreateHumidityRanges < ActiveRecord::Migration
  def change
    create_table :humidity_ranges do |t|
      t.decimal "min_rh", precision: 3, scale: 0
      t.decimal "max_rh", precision: 3, scale: 0
      t.decimal "score",      precision: 4, scale: 3
      t.integer "format_id"
      t.timestamps
    end
    add_index "humidity_ranges", ["format_id"], name: "index_humidity_ranges_on_format_id", using: :btree
    add_column :locations, :humidity_range_id, :integer
    add_index "locations", ["humidity_range_id"], name: "index_locations_on_humidity_range_id", using: :btree
    add_index "locations", ["temperature_range_id"], name: "index_locations_on_temperature_range_id", using: :btree
  end
end
