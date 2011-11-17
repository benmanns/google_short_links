class GoogleShortLinks::Client
  attr_accessor :server, :secret, :email

  def initialize options={}
    self.server = options[:server]
    self.secret = options[:secret]
    self.email = options[:email]
  end
end
