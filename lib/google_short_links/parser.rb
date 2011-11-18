require 'httparty'
require 'multi_json'

class GoogleShortLinks::Parser < HTTParty::Parser
  SupportedFormats = { 'text/html' => :json }

  def json
    MultiJson.decode(body)
  end
end
