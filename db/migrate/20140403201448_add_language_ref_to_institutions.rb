class AddLanguageRefToInstitutions < ActiveRecord::Migration
  def change
    add_reference :institutions, :language, index: true
  end
end
