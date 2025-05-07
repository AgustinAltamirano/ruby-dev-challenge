require 'json'
require_relative '../services/auth_service'
require_relative '../utils/response'
require 'jwt'
require 'rack'
require 'dry/schema'
require_relative '../models/user_schema'
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
    body = JSON.parse(req.body.read) rescue {}
    body_result = UserSchema.call(body)
    if body_result.errors.any?
      return response(400, { error: "Invalid request body", details: body_result.errors.to_h })
    end
    username = body_result[:username]
    password = body_result[:password]
    begin
      @auth_service.register_user(username, password)
      response(201, { message: "User registered successfully" })
    rescue AuthException => e
      response(400, { error: e })
    end
  end

  def login_user(req)
    body = JSON.parse(req.body.read) rescue {}
    body_result = UserSchema.call(body)
    if body_result.errors.any?
      return response(400, { error: "Invalid request body", details: body_result.errors.to_h })
    end
    username = body_result[:username]
    password = body_result[:password]
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
