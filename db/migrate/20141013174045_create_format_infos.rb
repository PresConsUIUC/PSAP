class CreateFormatInfos < ActiveRecord::Migration
  def change
    create_table :format_infos do |t|
      t.integer :format_class
      t.string :format_category
      t.string :name
      t.string :anchor
      t.text :images
      t.text :image_captions
      t.text :image_alts
      t.text :synonyms
      t.text :dates
      t.text :common_sizes
      t.text :description
      t.text :composition
      t.text :deterioration
      t.text :risk_level
      t.text :playback
      t.text :background
      t.text :storage_environment
      t.text :storage_enclosure
      t.text :storage_orientation
      t.text :handling_care
      t.text :cd_standard_specifications

      t.timestamps
    end
  end
end
