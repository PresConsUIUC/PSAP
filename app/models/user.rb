class User < ActiveRecord::Base
  has_many :assessments
  belongs_to :institution, inverse_of: :users
  belongs_to :role, inverse_of: :users

  has_secure_password

  # This regex is very lenient, but at least forces the user to put in some
  # effort. Strict email validation without rejecting valid addresses is
  # difficult with regex, and pretty pointless anyway.
  validates :email, presence: true, format: { with: /\S+@\S+\.\S+/ },
            uniqueness: { case_sensitive: false }
  validates :first_name, presence: true, length: { maximum: 255 }
  validates :last_name, presence: true, length: { maximum: 255 }
  validates :password, presence: true, length: { minimum: 6 },
            if: :validate_password?
  validates :role_id, presence: true
  validates :username, presence: true, length: { maximum: 255 },
            uniqueness: { case_sensitive: false },
            format: { with: /\A(?=.*[a-z])[a-z\d]+\Z/i,
                      message: 'Only letters and numbers are allowed.' }

  after_initialize :setup, if: :new_record?
  after_create :log_create
  after_update :log_update
  before_save { self.email = email.downcase }

  @@_current_user = nil
  @_log_update = true

  def to_param
    username
  end

  # Used by this and other models to associate the current user with event log
  # messages upon create/update/delete.
  def self.current_user
    @@_current_user
  end

  # Set by ApplicationController.init
  def self.current_user=(user)
    @@_current_user = user
  end

  def setup
    # generate a confirmation code
    require 'securerandom'
    self.confirmation_code ||= SecureRandom.hex
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

  # If set to false, the next ActiveRecord save will not be logged.
  def log_update?(boolean)
    @_log_update = boolean
  end

  def validate_password?
    password.present? || password_confirmation.present?
  end

  def log_create
    Event.create(description: "Created account for user #{self.username}",
                 user: User.current_user)
  end

  def log_update
    if @_log_update
      Event.create(description: "Edited user #{self.username}",
                   user: User.current_user)
    end
    @_log_update = true
  end

end
