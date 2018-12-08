class User < ApplicationRecord
  before_save { email.downcase! }
  VALID_EMAIL_FORMAT = /\A[\w+\-.]+@([\w+\-]+\.)*[a-z]+\z/i
  validates :name, presence: true, length: {maximum:50}
  validates :email, presence: true, length: {maximum:50},
              format: { with: VALID_EMAIL_FORMAT },
              uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: {minimum:6}
  has_secure_password
end
