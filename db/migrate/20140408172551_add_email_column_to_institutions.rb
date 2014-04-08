class AddEmailColumnToInstitutions < ActiveRecord::Migration
  def change
    add_column :institutions, :email, :string
  end
end
