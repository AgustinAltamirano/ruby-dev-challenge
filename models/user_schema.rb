require 'dry/schema'

UserSchema = Dry::Schema.JSON do
  config.validate_keys = true
  required(:username).filled(:string)
  required(:password).filled(:string)
end