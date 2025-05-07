require 'dry/schema'

ProductSchema = Dry::Schema.JSON do
  config.validate_keys = true
  required(:name).filled(:string)
end