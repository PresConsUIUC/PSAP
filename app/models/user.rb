class User < ActiveRecord::Base
  belongs_to :institution

  attr_accessor :email, :first_name, :last_name, :password_bcrypt,
                :password_salt, :username

  # TODO: validate email
  validates :first_name, length: { minimum: 1, maximum: 255 }
  validates :last_name, length: { minimum: 1, maximum: 255 }
  validates :username, length: { minimum: 2, maximum: 20 }

  def full_name
    @first_name + ' ' + @last_name
  end

  def has_permission(permission_key)
    # TODO: write this
  end

  def set_password(password)
    # TODO: write this
  end

end
