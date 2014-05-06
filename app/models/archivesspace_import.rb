# Used by the resource-import form.
class ArchivesspaceImport
  TRUE_VALUES = ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES

  include MockModel

  attr_accessor :host, :password, :port, :resource_id, :username

  validates :host, presence: true
  validates :password, presence: true
  validates :port, allow_blank: true, numericality: {
      greater_than_or_equal_to: 1, less_than_or_equal_to: 65536 }
  validates :resource_id, presence: true
  validates :username, presence: true

end
