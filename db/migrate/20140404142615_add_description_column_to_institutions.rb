class AddDescriptionColumnToInstitutions < ActiveRecord::Migration
  def change
    add_column :institutions, :description, :text
  end
end
