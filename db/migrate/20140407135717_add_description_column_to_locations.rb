class AddDescriptionColumnToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :description, :text
  end
end
