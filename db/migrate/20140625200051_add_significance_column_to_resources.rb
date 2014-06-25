class AddSignificanceColumnToResources < ActiveRecord::Migration
  def change
    add_column :resources, :significance, :decimal, precision: 1, scale: 1
  end
end
