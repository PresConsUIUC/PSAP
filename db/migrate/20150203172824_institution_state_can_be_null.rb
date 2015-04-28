class InstitutionStateCanBeNull < ActiveRecord::Migration
  def change
    change_column :institutions, :state, :string, null: true
  end
end
