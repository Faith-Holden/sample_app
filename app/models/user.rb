class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token

  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: "Relationship",
                                  foreign_key: "follower_id",
                                  dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship",
                                    foreign_key: "followed_id",
                                    dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower


  before_save :downcase_email
  before_create :create_activation_digest


  validates :name, presence: true, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255},
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  validates :password, presence: true, length: { minimum: 6}, allow_nil: true
  has_secure_password

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token)  )
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    
    BCrypt::Password.new(digest).is_password?(token)
  end

  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def send_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    self.update_columns(reset_digest: User.digest(self.reset_token), reset_sent_at: Time.zone.now)
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def feed
    following_ids = "SELECT followed_id FROM relationships
                      WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id", following_ids: following_ids, user_id: id)
  end

  def follow(user_to_follow)
    following << user_to_follow
  end

  def unfollow(user_to_unfollow)
    following.delete(user_to_unfollow)
  end

  def following?(user_to_check)
    following.include?(user_to_check)
  end


  
  class << self
  # Returns the hash digest of the given string.
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    # returns a random token
    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  #Private methods
  private
  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(self.activation_token)
  end
end
