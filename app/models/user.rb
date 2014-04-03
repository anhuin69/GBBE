class User < ActiveRecord::Base
  has_many :storages

  before_validation :initialize_defaults
  before_save :encrypt_password
  after_save :clear_password

  attr_accessor :password

  validates :email, :presence => true, :uniqueness => true, :format => /@/
  validates :username, :length => 0..255
  validates :password, :presence => true, :length => 6..48, :on => :create

  def self.authenticate_with_token(authentication_token)
    return false
  end

  def self.authenticate_with_credentials(params)
    user = User.find_by_email(params[:email])
    if (user && user.match_password(params[:password]) && user.generate_token)
      return user
    end
    return false
  end

  def match_password(login_password="")
    encrypted_password == BCrypt::Engine.hash_secret(login_password, salt)
  end

  def generate_token
    self.authentication_token = loop do
      random_token = SecureRandom.hex
      break random_token unless User.exists?(authentication_token: random_token)
    end
    return self.save
  end

  def as_json(options)
    super(:only => [:id, :email, :username])
  end

  def initialize_defaults
    self.username = ''
  end

  def encrypt_password
    if password.present?
      self.salt = BCrypt::Engine.generate_salt
      self.encrypted_password= BCrypt::Engine.hash_secret(password, salt)
    end
  end

  def clear_password
    self.password = nil
  end

end
