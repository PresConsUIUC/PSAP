class AddUniqueConstraints < ActiveRecord::Migration
  def change
    add_index :institutions, :name, unique: true

    add_index :languages, :english_name, unique: true
    add_index :languages, :iso639_2_code, unique: true

    add_index :permissions, :key, unique: true

    add_index :roles, :name, unique: true

    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
  end
end
