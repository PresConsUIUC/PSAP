class DropInstitutionTypesTable < ActiveRecord::Migration
  def change
    drop_table :institution_types
  end
end
