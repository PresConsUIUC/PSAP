class User < ActiveRecord::Base
  has_and_belongs_to_many :events
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

  after_initialize :setup, if: :new_record?
  before_save { self.email = email.downcase }

  ##
  # Returns a list of "most active users" based on the number of
  # resources they've created/updated.
  #
  # @return Array of hashes containing :count and :user keys
  #
  def self.most_active(limit = 5) # TODO: test this
    sql = "SELECT COUNT(description) AS count, users.id AS user_id "\
          "FROM users "\
          "LEFT JOIN events_users ON users.id = events_users.user_id "\
          "LEFT JOIN events ON events_users.event_id = events.id "\
          "WHERE events.description LIKE 'Created resource%' "\
            "OR events.description LIKE 'Updated resource%' "\
          "GROUP BY description "\
          "ORDER BY count DESC "\
          "LIMIT #{limit}"
    connection = ActiveRecord::Base.connection
    counts = connection.execute(sql)

    counts.map{ |r| { count: r[:count],
                      user: User.find(r[:user_id]) } }
  end

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
