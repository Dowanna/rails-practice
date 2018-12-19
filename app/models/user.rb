class User < ApplicationRecord
  attr_accessor :remember_token
  before_save { email.downcase! }
  VALID_EMAIL_FORMAT = /\A[\w+\-.]+@([\w+\-]+\.)*[a-z]+\z/i
  validates :name, presence: true, length: {maximum:50}
  validates :email, presence: true, length: {maximum:50},
              format: { with: VALID_EMAIL_FORMAT },
              uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: {minimum:6}, allow_nil: true
  has_secure_password

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
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
end
