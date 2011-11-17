class GoogleShortLinks::Client
  attr_accessor :server, :secret, :email

  def initialize options={}
    self.server = options[:server]
    self.secret = options[:secret]
    self.email = options[:email]
  end

  protected

  def request_path action
    "http://#{server}/js/#{action}"
  end
end
