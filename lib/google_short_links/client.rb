require 'cgi'
require 'base64'
require 'digest/sha1'
require 'openssl'
require 'uri'

require 'httparty'

# Client for Google Short Links.
#
# ==== Examples
#
#   client = GoogleShortLinks::Client.new :server => 'short.example.com', :secret => 'abcdef1234567890', :email => 'ben@example.com'
#   link = client.get_or_create_hash 'http://example.com/parent/child/long_document_name.html', :is_public => true
#   link # => {"status"=>"ok", "url"=>"http://example.com/parent/child/long_document_name.html", "estimated_api_calls_remaining"=>98, "shortcut"=>"abc12", "usage_count"=>0, "owner"=>"ben@example.com", "is_public"=>true, "is_hash"=>true}
class GoogleShortLinks::Client
  include HTTParty

  # The domain name where Google Short Links is hosted.
  attr_accessor :server

  # Your HMAC-SHA1 secret.
  attr_accessor :secret

  # The email for the account under which the links will be created.
  attr_accessor :email

  parser GoogleShortLinks::Parser

  # Initializes a new Client.
  #
  # ==== Parameters
  #
  # [<tt>options</tt>] Optional Hash containing configuration values.
  #
  # ==== Options
  #
  # [:server]
  #   The domain name where Google Short Links is hosted.
  # [:secret]
  #   Your HMAC-SHA1 secret.
  # [:email]
  #   The email for the account under which the links will be created.
  def initialize options={}
    self.server = options[:server]
    self.secret = options[:secret]
    self.email = options[:email]
  end

  # Creates a URL that is used to create a hash.
  #
  # ==== Parameters
  #
  # [<tt>url</tt>] Required String containing the URL to be shortened.
  # [<tt>params</tt>] Optional Hash that will add or override GET parameters in the URL.
  #
  # ==== Parameters
  #
  # [:is_public]
  #   Boolean for whether or not the short link can be accessed without logging in to Google Apps.
  #
  # ==== Examples
  #
  #   link_url = client.get_or_create_hash_url 'http://example.com/parent/child/long_document_name.html', :is_public => true
  #   link_url # => "http://short.example.com/js/get_or_create_hash?is_public=true&oauth_signature_method=HMAC-SHA1&timestamp=1321663459.0&url=http%3A%2F%2Fexample.com%2Fparent%2Fchild%2Flong_document_name.html&user=ben%40example.com&oauth_signature=JElQ0Oq59q%2BOsinYuMzGX%2F8Tn2U%3D"
  def get_or_create_hash_url url, params={}
    request_path = request_path(:get_or_create_hash)

    query = params_to_query(base_params.merge(:url => url).merge(params))

    digest_url(request_path, query)
  end

  # Creates a URL that is used to create a shortlink with a customized shortcut.
  #
  # ==== Parameters
  #
  # [<tt>url</tt>] Required String containing the URL to be shortened.
  # [<tt>shortcut</tt>] Required String containing the custom shortcut.
  # [<tt>params</tt>] Optional Hash that will add or override GET parameters in the URL.
  #
  # ==== Parameters
  #
  # [:is_public]
  #   Boolean for whether or not the short link can be accessed without logging in to Google Apps.
  #
  # ==== Examples
  #
  #   link_url = client.get_or_create_shortlink_url 'http://example.com/parent/child/long_document_name.html', 'example', :is_public => true
  #   link_url # => "http://short.example.com/js/get_or_create_shortlink?is_public=true&oauth_signature_method=HMAC-SHA1&shortcut=example&timestamp=1321663613.0&url=http%3A%2F%2Fexample.com%2Fparent%2Fchild%2Flong_document_name.html&user=ben%40example.com&oauth_signature=FsOEjCDw3qpz%2B59Pdi4d1Qvv0Os%3D"
  def get_or_create_shortlink_url url, shortcut, params={}
    request_path = request_path(:get_or_create_shortlink)

    query = params_to_query(base_params.merge(:url => url, :shortcut => shortcut).merge(params))

    digest_url(request_path, query)
  end

  # Creates a URL that is used to get details about a link from its shortcut.
  #
  # ==== Parameters
  #
  # [<tt>shortcut</tt>] Required String containing the URL to be shortened.
  # [<tt>params</tt>] Optional Hash that will add or override GET parameters in the URL.
  #
  # ==== Examples
  #
  #   link_url = client.get_details_url 'example'
  #   link_url # => "http://short.example.com/js/get_details?oauth_signature_method=HMAC-SHA1&shortcut=example&timestamp=1321663629.0&user=ben%40example.com&oauth_signature=p8XqzF0lITupKN3Ta0qu2E8hqBI%3D"
  def get_details_url shortcut, params={}
    request_path = request_path(:get_details)

    query = params_to_query(base_params.merge(:shortcut => shortcut).merge(params))

    digest_url(request_path, query)
  end

  # Shortens a URL.
  #
  # ==== Parameters
  #
  # [<tt>url</tt>] Required String containing the URL to be shortened.
  # [<tt>params</tt>] Optional Hash that will add or override GET parameters in the URL.
  #
  # ==== Parameters
  #
  # [:is_public]
  #   Boolean for whether or not the short link can be accessed without logging in to Google Apps.
  #
  # ==== Examples
  #
  #   link = client.get_or_create_hash 'http://example.com/parent/child/long_document_name.html', :is_public => true
  #   link # => {"status"=>"ok", "url"=>"http://example.com/parent/child/long_document_name.html", "estimated_api_calls_remaining"=>98, "shortcut"=>"abc12", "usage_count"=>0, "owner"=>"ben@example.com", "is_public"=>true, "is_hash"=>true}
  def get_or_create_hash url, params={}
    self.class.get(get_or_create_hash_url(url, params)).parsed_response
  end

  # Creates a shortlink with a customized shortcut.
  #
  # ==== Parameters
  #
  # [<tt>url</tt>] Required String containing the URL to be shortened.
  # [<tt>shortcut</tt>] Required String containing the custom shortcut.
  # [<tt>params</tt>] Optional Hash that will add or override GET parameters in the URL.
  #
  # ==== Parameters
  #
  # [:is_public]
  #   Boolean for whether or not the short link can be accessed without logging in to Google Apps.
  #
  # ==== Examples
  #
  #   link = client.get_or_create_shortlink 'http://example.com/parent/child/long_document_name.html', 'example', :is_public => true
  #   link # => {"status"=>"ok", "url"=>"http://example.com/parent/child/long_document_name.html", "estimated_api_calls_remaining"=>99, "shortcut"=>"example", "usage_count"=>0, "owner"=>"ben@example.com", "is_public"=>true, "is_hash"=>false}
  def get_or_create_shortlink url, shortcut, params={}
    self.class.get(get_or_create_shortlink_url(url, shortcut, params)).parsed_response
  end

  # Gets details about a link from its shortcut.
  #
  # ==== Parameters
  #
  # [<tt>shortcut</tt>] Required String containing the URL to be shortened.
  # [<tt>params</tt>] Optional Hash that will add or override GET parameters in the URL.
  #
  # ==== Examples
  #
  #   link = client.get_details 'example'
  #   link # => {"status"=>"ok", "url"=>"http://example.com/parent/child/long_document_name.html", "estimated_api_calls_remaining"=>100, "shortcut"=>"example", "usage_count"=>0, "owner"=>"ben@example.com", "is_public"=>true, "is_hash"=>false}
  def get_details shortcut, params={}
    self.class.get(get_details_url(shortcut, params)).parsed_response
  end

  protected

  def request_path action #:nodoc:
    "http://#{server}/js/#{action}"
  end

  def base_params #:nodoc:
    {
      :oauth_signature_method => 'HMAC-SHA1',
      :timestamp => Time.now.to_i.to_f,
      :user => email,
    }
  end

  def params_to_query params #:nodoc:
    params.to_a.sort_by { |param| param.to_s }.map { |(key, value)| "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}" }.join('&')
  end

  def digest request_path, query #:nodoc:
    content = "GET&#{CGI.escape(request_path)}&#{CGI.escape(query)}"

    digest = OpenSSL::Digest::Digest.new('sha1')
    digest_raw = OpenSSL::HMAC.digest(digest, secret, content)
    CGI.escape(Base64.encode64(digest_raw).chomp)
  end

  def digest_url request_path, query #:nodoc:
    request_uri = URI.parse(request_path)
    request_uri.query = "#{query}&oauth_signature=#{digest(request_path, query)}"
    request_uri.to_s
  end
end
