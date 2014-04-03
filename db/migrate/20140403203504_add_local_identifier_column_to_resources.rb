class AddLocalIdentifierColumnToResources < ActiveRecord::Migration
  def change
    add_column :resources, :local_identifier, :string
  end
end
