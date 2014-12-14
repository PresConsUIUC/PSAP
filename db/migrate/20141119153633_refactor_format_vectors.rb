class RefactorFormatVectors < ActiveRecord::Migration
  def up
    remove_column :format_ink_media_types, :format_id
    remove_column :format_ink_media_types, :format_vector_group_id
    remove_column :format_ink_media_types, :group
    add_column :resources, :format_ink_media_type_id, :integer

    remove_column :format_support_types, :format_id
    remove_column :format_support_types, :format_vector_group_id
    remove_column :format_support_types, :group
    add_column :resources, :format_support_type_id, :integer

    drop_table :format_vector_groups
  end

  def down
    add_column :format_ink_media_types, :format_id, :integer
    add_column :format_ink_media_types, :format_vector_group_id, :integer
    add_column :format_ink_media_types, :group, :string
    remove_column :resources, :format_ink_media_type_id

    add_column :format_support_types, :format_id, :integer
    add_column :format_support_types, :format_vector_group_id, :integer
    add_column :format_support_types, :group, :string
    remove_column :resources, :format_support_type_id

    create_table :format_vector_groups do |t|
      t.integer :format_ink_media_type_id
      t.integer :format_support_type_id
      t.string :name
      t.timestamps
    end
  end
end
