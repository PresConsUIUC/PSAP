class InstitutionPostalCodeCanBeNull < ActiveRecord::Migration
  def change
    change_column :institutions, :postal_code, :string, null: true
  end
end
