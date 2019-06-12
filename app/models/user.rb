class User < ApplicationRecord
  belongs_to :desired_institution, class_name: 'Institution',
             foreign_key: 'desired_institution_id', optional: true
  has_and_belongs_to_many :events
  belongs_to :institution, inverse_of: :users, optional: true
  has_many :resources, -> { order(:name) }, inverse_of: :user
  belongs_to :role, inverse_of: :users

  has_secure_password

  validates :about, presence: true
  # Strict email validation without rejecting valid addresses is difficult,
  # but this will at least require something vaguely email-like.
  validates :email, presence: true, format: { with: /\S+@\S+\.\S+/ },
            uniqueness: { case_sensitive: false }
  validates :feed_key, presence: true, length: { maximum: 255 }
  validates :first_name, presence: true, length: { maximum: 255 }
  validates :last_name, presence: true, length: { maximum: 255 }
  validates :password, presence: true, length: { minimum: 6 },
            if: :validate_password?
  validates :role_id, presence: true
  validates :username, presence: true, length: { maximum: 20 },
            uniqueness: { case_sensitive: false },
            format: { with: /\A(?=.*[a-z])[a-z\d]+\Z/i,
                      message: 'Only letters and numbers are allowed.' }

  after_initialize :setup, if: :new_record?
  before_save { self.email = email.downcase }

  def setup
    # generate a confirmation code
    require 'securerandom'
    self.confirmation_code ||= SecureRandom.hex

    self.reset_feed_key unless self.feed_key
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def has_permission?(key)
    self.role.has_permission?(key)
  end

  def is_admin?
    self.role.is_admin?
  end

  def reset_feed_key
    self.feed_key = SecureRandom.hex
  end

  def reset_password_reset_key
    self.password_reset_key = SecureRandom.urlsafe_base64(nil, false)
  end

  def to_param
    username
  end

  def to_s
    username
  end

  def validate_password?
    password.present? or password_confirmation.present?
  end

end
