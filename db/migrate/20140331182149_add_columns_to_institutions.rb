class AddColumnsToInstitutions < ActiveRecord::Migration
  def change
    add_column :institutions, :address1, :string
    add_column :institutions, :address2, :string
    add_column :institutions, :city, :string
    add_column :institutions, :state, :string
    add_column :institutions, :postal_code, :string
  end
end
