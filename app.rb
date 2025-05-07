# app.rb
require 'rack'
require 'json'
require 'logger'
require_relative 'utils/response'
require 'dry/schema'
require_relative 'models/product_schema'
require_relative 'services/product_service'

class App
  def initialize
    @product_service = ProductService.new
  end

  def call(env)
    logger = Logger.new($stdout)
    req = Rack::Request.new(env)
    logger.info "#{req.request_method} #{req.path_info}"
    case req.request_method
    when 'POST'
      case req.path_info
      when '/products'
        return handle_create_product(req)
      else
        return not_found
      end
    when 'GET'
      case req.path_info
      when '/products'
        return handle_list_products
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

  def handle_create_product(req)
    body = JSON.parse(req.body.read) rescue {}
    body_result = ProductSchema.call(body)
    if body_result.errors.any?
      return response(400, { error: "Invalid request body", details: body_result.errors.to_h })
    end
    name = body_result[:name]
    product_id = @product_service.create_product(name)
    response(202, { message: "Product creation scheduled", id: product_id })
  end

  def handle_list_products
    response(200, @product_service.list_products)
  end

  def handle_get_product(req)
    product_id = req.path_info.split('/').last.to_i
    begin
      response(200, @product_service.get_product(product_id))
    rescue ProductException => e
      response(400, { error: e })
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
end
