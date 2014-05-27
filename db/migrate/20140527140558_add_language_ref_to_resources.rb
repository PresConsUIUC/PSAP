class AddLanguageRefToResources < ActiveRecord::Migration
  def change
    add_reference :resources, :language
  end
end
