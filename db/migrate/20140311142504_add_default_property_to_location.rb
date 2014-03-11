class AddDefaultPropertyToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :is_default, :boolean
  end
end
