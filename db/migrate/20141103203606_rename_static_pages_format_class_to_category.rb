class RenameStaticPagesFormatClassToCategory < ActiveRecord::Migration
  def change
    remove_column :static_pages, :format_class
    add_column :static_pages, :category, :string
  end
end
