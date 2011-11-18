require 'cgi'
require 'base64'
require 'digest/sha1'
require 'openssl'
require 'uri'

require 'httparty'

class GoogleShortLinks::Client
  include HTTParty

  attr_accessor :server, :secret, :email

  def initialize options={}
    self.server = options[:server]
    self.secret = options[:secret]
    self.email = options[:email]
  end

  def get_or_create_hash_url url, params={}
    request_path = request_path(:get_or_create_hash)

    query = params_to_query(base_params.merge(:url => url).merge(params))

    digest_url(request_path, query)
  end

  def get_or_create_shortlink_url url, shortcut, params={}
    request_path = request_path(:get_or_create_shortlink)

    query = params_to_query(base_params.merge(:url => url, :shortcut => shortcut).merge(params))

    digest_url(request_path, query)
  end

  def get_details_url shortcut, params={}
    request_path = request_path(:get_details)

    query = params_to_query(base_params.merge(:shortcut => shortcut).merge(params))

    digest_url(request_path, query)
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
    params.to_a.sort_by { |param| param.to_s }.map { |(key, value)| "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}" }.join('&')
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
