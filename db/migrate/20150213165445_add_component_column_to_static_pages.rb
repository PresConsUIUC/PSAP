class AddComponentColumnToStaticPages < ActiveRecord::Migration
  def change
    add_column :static_pages, :component, :string
  end
end
