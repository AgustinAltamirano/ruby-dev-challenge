require 'json'
require_relative 'auth_service'
require_relative '../utils/response'
require 'jwt'
require 'rack'

class AuthMiddleware
  def initialize(app)
    @app = app
    @auth_service = AuthService.new
  end

  def call(env)
    req = Rack::Request.new(env)
    path = req.path_info
    case [req.request_method, path]
    when %w[POST /register]
      return register_user(req)
    when %w[GET /login]
      return login_user(req)
    else
      if path == "/openapi.yaml" || path == "/AUTHORS"
        return @app.call(env)
      else
        handle_protected_route(env)
      end
    end
  end

  private
  def register_user(req)
    data = JSON.parse(req.body.read) rescue {}
    username = data['username']
    password = data['password']
    begin
      @auth_service.register_user(username, password)
      response(201, { message: "User registered successfully" })
    rescue AuthException => e
      response(400, { error: e })
    end
  end

  def login_user(req)
    data = JSON.parse(req.body.read) rescue {}
    puts "hola"
    username = data['username']
    password = data['password']
    begin
      token = @auth_service.login_user(username, password)
      response(200, { token: token, expires_in: AuthService.expiration_time })
    rescue AuthException => e
      response(401, { error: e })
    end
  end

  def handle_protected_route(env)
    token = env['HTTP_AUTHORIZATION']&.split(' ')&.last
    begin
      AuthService.decode_token(token)
      @app.call(env)
    rescue JWT::DecodeError
      response(401, { error: "Invalid token" })
    end
  end

end
