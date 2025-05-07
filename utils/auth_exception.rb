class AuthException < StandardError
  @message

  def initialize( message)
    @message = message
  end

  def to_s
    "##{@message}"
  end
end