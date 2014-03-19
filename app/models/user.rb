class User < ActiveRecord::Base
  belongs_to :institution, inverse_of: :users
  belongs_to :role, inverse_of: :users

  has_secure_password

  # TODO: improve email validation
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
  validates :first_name, presence: true, length: { maximum: 255 }
  validates :institution_id, presence: true
  validates :last_name, presence: true, length: { maximum: 255 }
  validates :password, length: { minimum: 6 }, if: :validate_password? # TODO: externalize this
  validates :role_id, presence: true
  validates :username, presence: true, length: { maximum: 255 },
            uniqueness: { case_sensitive: false }

  after_initialize :setup, if: :new_record?
  after_create :log_create
  after_update :log_update
  before_save { self.email = email.downcase }

  @@_current_user = nil
  @_log_update = true

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
    Event.create(description: "Created user account #{self.username}, affiliated with #{self.institution.name}",
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
