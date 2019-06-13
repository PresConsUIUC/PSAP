##
# A Repository exists within an Institution. It can contain zero or more
# Locations.
#
# Repositories are not assessable.
#
class Repository < ApplicationRecord

  belongs_to :institution, inverse_of: :repositories
  has_many :locations, -> { order(:name) }, inverse_of: :repository,
           dependent: :destroy
  has_many :resources, -> { order(:name) }, through: :locations

  validates :institution, presence: true
  validates :name, presence: true, length: { maximum: 255 }

  validates_uniqueness_of :name, scope: :institution_id

  ##
  # Used by `Institution.import()`.
  #
  # @param struct [Hash]
  # @param location_id [Integer]
  # @return [Repository]
  #
  def self.import(struct, institution_id)
    repo = Repository.create!(created_at: struct['created_at'],
                              updated_at: struct['updated_at'],
                              institution_id: institution_id,
                              name: struct['name'])
    struct['locations'].each do |loc|
      Location.import(loc, repo.id)
    end
    repo
  end

  ##
  # @return [ActiveRecord::Relation<Resource>]
  #
  def collections
    self.resources.where(resource_type: Resource::Type::COLLECTION)
  end

  ##
  # Exports all of an instance's associated content.
  #
  # @see `Institution.full_export_as_json()`
  # @return [Hash]
  #
  def full_export_as_json
    struct = self.as_json
    struct[:locations] = self.locations.map { |loc| loc.full_export_as_json }
    struct
  end

end
