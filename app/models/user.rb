class User < ActiveRecord::Base
  belongs_to :institution

  has_secure_password

  # TODO: improve email validation
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
  validates :first_name, presence: true, length: { minimum: 1, maximum: 255 }
  validates :last_name, presence: true, length: { minimum: 1, maximum: 255 }
  validates :password, length: { minimum: 6 } # TODO: externalize this

  before_save { self.email = email.downcase }

  def full_name
    "#{first_name} #{last_name}"
  end

  def has_permission(permission_key)
    # TODO: write this
  end

end
