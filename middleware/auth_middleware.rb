# middleware/auth_middleware.rb
require 'json'

class AuthMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    path = req.path_info

    if path == "/auth" || path == "/openapi.yaml" || path == "/AUTHORS"
      return @app.call(env)
    end

    auth_header = req.get_header("HTTP_AUTHORIZATION")
    if auth_header && auth_header == "Bearer secrettoken"
      env["authenticated"] = true
      @app.call(env)
    else
      [401, { "Content-Type" => "application/json" }, [ { error: "Unauthorized" }.to_json ]]
    end
  end
end
