class RefactorFormatInfos < ActiveRecord::Migration
  def change
    remove_column :format_infos, :anchor
    remove_column :format_infos, :images
    remove_column :format_infos, :image_captions
    remove_column :format_infos, :image_alts
    remove_column :format_infos, :synonyms
    remove_column :format_infos, :dates
    remove_column :format_infos, :common_sizes
    remove_column :format_infos, :description
    remove_column :format_infos, :composition
    remove_column :format_infos, :deterioration
    remove_column :format_infos, :risk_level
    remove_column :format_infos, :playback
    remove_column :format_infos, :background
    remove_column :format_infos, :storage_environment
    remove_column :format_infos, :storage_enclosure
    remove_column :format_infos, :storage_orientation
    remove_column :format_infos, :handling_care
    remove_column :format_infos, :cd_standard_specifications
  end
end
