class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  has_many :active_relationships,
    class_name: 'Relationship',
    foreign_key: 'follower_id',
    dependent: :destroy
  has_many :passive_relationships,
    class_name: 'Relationship',
    foreign_key: 'followed_id',
    dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships
  attr_accessor :reset_token, :remember_token, :activation_token
  before_create :create_activation_digest
  before_save :downcase_email
  VALID_EMAIL_FORMAT = /\A[\w+\-.]+@([\w+\-]+\.)*[a-z]+\z/i
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 50 },
                    format: { with: VALID_EMAIL_FORMAT },
                    uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  has_secure_password

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  def save_reset_digest
    self.reset_token = User.new_token # mailerの中から参照する
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def feed
    Micropost.where('user_id=?', id)
  end 

  def follow(other_user)
    following << other_user
  end

  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  def following?(user)
    following.include?(user)
  end

  class << self
    # 渡された文字列をハッシュ化する
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    # ランダムなトークンを生成する
    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  private

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

  def downcase_email
    email.downcase!
  end
end
