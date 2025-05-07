require 'zlib'
require 'stringio'
class CompressionMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)

    accept_encoding = env['HTTP_ACCEPT_ENCODING'] || ""
    if accept_encoding.include?("gzip")
      compressed = gzip(body.join)

      headers['Content-Encoding'] = 'gzip'
      headers['Content-Length'] = compressed.bytesize.to_s
      headers['Vary'] = 'Accept-Encoding'
      [status, headers, [compressed]]
    else
      [status, headers, body]
    end
  end

  private

  def gzip(string)
    io = StringIO.new
    gz = Zlib::GzipWriter.new(io)
    gz.write(string)
    gz.close
    io.string
  end
end