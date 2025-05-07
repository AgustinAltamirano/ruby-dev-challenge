require_relative '../utils/product_exception'

class ProductService
  def initialize
    @products = {}
    @pending = []
    @next_product_id = 1
  end

  def create_product(name)
    id = @next_product_id
    @next_product_id += 1

    Thread.new do
      sleep 5
      @products[id] = { id: id, name: name }
    end
    id
  end

  def list_products
    @products.values
  end

  def get_product(id)
    product = @products[id]
    unless product
      raise ProductException.new("Product with ID #{id} not found")
    end
    product
  end
end