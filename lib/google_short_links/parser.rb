require 'httparty'
require 'multi_json'

# Parses the JSON that Google Short Links returns.
class GoogleShortLinks::Parser < HTTParty::Parser
  # Google returns the JSON response as a text/html mime type.
  # This class only supports JSON currently.
  SupportedFormats = { 'text/html' => :json }

  # Decodes JSON into a hash.
  def json
    MultiJson.decode(body)
  end
end
