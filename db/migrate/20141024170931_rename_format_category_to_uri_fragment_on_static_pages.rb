class RenameFormatCategoryToUriFragmentOnStaticPages < ActiveRecord::Migration
  def change
    rename_column :static_pages, :format_category, :uri_fragment
  end
end
