require 'cgi'
require 'uri'

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

  def base_params
    {
      :oauth_signature_method => 'HMAC-SHA1',
      :timestamp => Time.now.to_i.to_f,
      :user => email,
    }
  end

  def params_to_query params
    params.to_a.sort.map { |(key, value)| "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}" }.join('&')
  end
end
