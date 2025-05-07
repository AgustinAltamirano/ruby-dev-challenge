require_relative 'app'
require_relative 'middleware/compression_middleware'
require_relative 'middleware/auth_middleware'

use CompressionMiddleware
use AuthMiddleware
run App.new