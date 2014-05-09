class AddRightsColumnToResources < ActiveRecord::Migration
  def change
    add_column :resources, :rights, :string
  end
end
