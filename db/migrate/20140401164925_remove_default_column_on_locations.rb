class RemoveDefaultColumnOnLocations < ActiveRecord::Migration
  def change
    remove_column :locations, :is_default
  end
end
