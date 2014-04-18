class DropInstitutionTypesTable < ActiveRecord::Migration
  def change
    drop_table :institution_types if table_exists? :institution_types
  end
end
