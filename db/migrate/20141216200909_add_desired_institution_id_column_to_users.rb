class AddDesiredInstitutionIdColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :desired_institution_id, :integer
  end
end
