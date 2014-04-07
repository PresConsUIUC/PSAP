class AddDateColumnsToResources < ActiveRecord::Migration
  def change
    add_column :resources, :date_type, :integer
    add_column :resources, :year, :decimal, precision:4, scale: 0
    add_column :resources, :begin_year, :decimal, precision: 4, scale: 0
    add_column :resources, :end_year, :decimal, precision: 4, scale: 0
  end
end
