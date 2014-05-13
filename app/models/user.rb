class User < ActiveRecord::Base
  belongs_to :institution, inverse_of: :users
  has_many :resources, inverse_of: :user
  belongs_to :role, inverse_of: :users

  has_secure_password

  # This regex is very lenient, but at least forces the user to put in some
  # effort. Strict email validation without rejecting valid addresses is
  # difficult with regex, and pretty pointless anyway.
  validates :email, presence: true, format: { with: /\S+@\S+\.\S+/ },
            uniqueness: { case_sensitive: false }
  validates :feed_key, presence: true, length: { maximum: 255 }
  validates :first_name, presence: true, length: { maximum: 255 }
  validates :last_name, presence: true, length: { maximum: 255 }
  validates :password, presence: true, length: { minimum: 6 },
            if: :validate_password?
  validates :role_id, presence: true
  validates :username, presence: true, length: { maximum: 255 },
            uniqueness: { case_sensitive: false },
            format: { with: /\A(?=.*[a-z])[a-z\d]+\Z/i,
                      message: 'Only letters and numbers are allowed.' }
  validate :forbid_changing_username

  def forbid_changing_username
    errors[:username] = 'Username cannot be changed' if
        self.username_changed? && !self.is_admin?
  end

  after_initialize :setup, if: :new_record?
  before_save { self.email = email.downcase }

  def to_param
    username
  end

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

  def validate_password?
    password.present? || password_confirmation.present?
  end

end
