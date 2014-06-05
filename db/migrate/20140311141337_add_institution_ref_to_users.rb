class AddInstitutionRefToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :institution, index: true
  end
end
