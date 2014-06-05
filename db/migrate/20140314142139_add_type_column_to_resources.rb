class AddTypeColumnToResources < ActiveRecord::Migration
  def change
    add_column :resources, :resource_type, :integer
  end
end
