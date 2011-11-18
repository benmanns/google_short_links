require 'cgi'
require 'base64'
require 'openssl'
require 'digest/sha1'
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

  def digest request_path, query
    content = "GET&#{CGI.escape(request_path)}&#{CGI.escape(query)}"

    digest = OpenSSL::Digest::Digest.new('sha1')
    digest_raw = OpenSSL::HMAC.digest(digest, secret, content)
    CGI.escape(Base64.encode64(digest_raw).chomp)
  end

  def digest_url request_path, query
    request_uri = URI.parse(request_path)
    request_uri.query = "#{query}&oauth_signature=#{digest(request_path, query)}"
    request_uri.to_s
  end
end
