class AddInstitutionRefToRepositories < ActiveRecord::Migration
  def change
    add_reference :repositories, :institution, index: true
  end
end
