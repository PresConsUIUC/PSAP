class User < ActiveRecord::Base
  belongs_to :institution, inverse_of: :users
  belongs_to :role, inverse_of: :users

  has_secure_password

  # TODO: improve email validation
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
  validates :first_name, presence: true, length: { minimum: 1, maximum: 255 }
  validates :institution_id, presence: true
  validates :last_name, presence: true, length: { minimum: 1, maximum: 255 }
  validates :password, length: { minimum: 6 } # TODO: externalize this
  validates :role_id, presence: true

  before_save { self.email = email.downcase }

  def full_name
    "#{first_name} #{last_name}"
  end

  def has_permission?(key)
    self.role.has_permission?(key)
  end

  def is_admin?
    self.role.is_admin?
  end

end
