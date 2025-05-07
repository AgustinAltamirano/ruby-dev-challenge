require_relative 'app'
require_relative 'middleware/auth_middleware'

use AuthMiddleware
run App.new