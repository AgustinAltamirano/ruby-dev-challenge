require 'jwt'

require_relative '../utils/auth_exception'

class AuthService
  SECRET_KEY = 'secrettoken'
  ALGORITHM = 'HS256'
  EXPIRATION_TIME_SECONDS = 3600 # 1 hour

  def initialize
    @users = {}
  end

  def register_user(username, password)
    if @users[username]
      raise AuthException.new("Username already taken")
    end
    @users[username] = password
  end

  def login_user(username, password)
    unless @users[username]
      raise AuthException.new("User not found")
    end
    unless @users[username] == password
      raise AuthException.new("Invalid password")
    end
    payload = { username: username }
    AuthService.encode_token(payload)
  end

  def self.encode_token(payload)
    exp = Time.now.to_i + EXPIRATION_TIME_SECONDS
    exp_payload = { :data => payload, :exp => exp }
    JWT.encode(exp_payload, SECRET_KEY, ALGORITHM)
  end

  def self.decode_token(token)
    JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM })
  end

  def self.valid_token?(token)
    !!decode_token(token)
  end

  def self.expiration_time
    EXPIRATION_TIME_SECONDS
  end

end