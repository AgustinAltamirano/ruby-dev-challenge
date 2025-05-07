# app.rb
require 'rack'
require 'json'
require 'logger'

class App
  def initialize
    @products = {}
    @pending = []
  end

  def call(env)
    logger = Logger.new($stdout)
    req = Rack::Request.new(env)
    logger.info "#{req.request_method} #{req.path_info}"
    case req.request_method
    when 'POST'
      case req.path_info
      when '/auth'
        return handle_auth(req)
      when '/products'
        return handle_create_product(req)
      else
        return not_found
      end
    when 'GET'
      case req.path_info
      when '/products'
        return handle_list_products(req)
      when /^\/products\/(\d+)$/
        return handle_get_product(req)
      when '/openapi.yaml'
        return serve_static_file('static/openapi.yaml', cache: false)
      when '/AUTHORS'
        return serve_static_file('static/AUTHORS', cache: true)
      else
        return not_found
      end
    else
      not_found
    end
  end

  private

  def handle_auth(req)
    data = JSON.parse(req.body.read) rescue {}
    if data['username'] == 'admin' && data['password'] == 'secret'
      response(200, { token: 'secrettoken' })
    else
      response(401, { error: 'Invalid credentials' })
    end
  end

  def handle_create_product(req)
    data = JSON.parse(req.body.read) rescue {}
    id = rand(1000..9999)
    name = data["name"] || "Unnamed"

    Thread.new do
      sleep 5
      @products[id] = { id: id, name: name }
    end

    response(202, { message: "Product creation scheduled", id: id })
  end

  def handle_list_products(req)
    response(200, @products.values)
  end

  def handle_get_product(req)
    id = req.path_info.split('/').last.to_i
    product = @products[id]
    if product
      response(200, product)
    else
      response(404, { error: "Product not found" })
    end
  end

  def serve_static_file(path, cache:)
    return not_found unless File.exist?(path)

    headers = {
      "Content-Type" => content_type(path)
    }
    headers["Cache-Control"] = cache ? "public, max-age=86400" : "no-cache"

    [200, headers, [File.read(path)]]
  end

  def content_type(path)
    case File.extname(path)
    when ".yaml" then "application/yaml"
    when ".yml"  then "application/yaml"
    else "text/plain"
    end
  end

  def not_found
    response(404, { error: "Not found" })
  end

  def response(status, body)
    [status, { "Content-Type" => "application/json" }, [body.to_json]]
  end
end
