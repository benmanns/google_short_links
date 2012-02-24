require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe GoogleShortLinks::Client do
  if ENV['GOOGLE_SHORT_LINKS_SERVER'] && ENV['GOOGLE_SHORT_LINKS_SECRET'] && ENV['GOOGLE_SHORT_LINKS_EMAIL']
    let(:client) { GoogleShortLinks::Client.new(:server => ENV['GOOGLE_SHORT_LINKS_SERVER'], :secret => ENV['GOOGLE_SHORT_LINKS_SECRET'], :email => ENV['GOOGLE_SHORT_LINKS_EMAIL']) }

    specify 'creating a hash' do
      require 'securerandom'
      url = "http://www.example.org/#{SecureRandom.uuid}"

      response = client.get_or_create_hash(url)
      response = client.get_or_create_hash(url) if response['status'] == 'not found'

      response.should include 'url' => url
      response.should have_key 'shortcut'
      response.should include 'owner' => ENV['GOOGLE_SHORT_LINKS_EMAIL']
      response.should include 'is_public' => false
      response.should include 'is_hash' => true

      shortcut = response['shortcut']

      response = client.get_or_create_hash(url)

      response.should include 'url' => url
      response.should include 'shortcut' => shortcut
      response.should include 'owner' => ENV['GOOGLE_SHORT_LINKS_EMAIL']
      response.should include 'is_public' => false
      response.should include 'is_hash' => true

      response = client.get_details(shortcut)

      response.should include 'url' => url
      response.should include 'shortcut' => shortcut
      response.should include 'owner' => ENV['GOOGLE_SHORT_LINKS_EMAIL']
      response.should include 'is_public' => false
      response.should include 'is_hash' => true
    end

    specify 'creating a shortcut' do
      require 'securerandom'
      url = "http://www.example.org/#{SecureRandom.uuid}"
      shortcut = SecureRandom.uuid

      response = client.get_or_create_shortlink(url, shortcut)
      response = client.get_or_create_shortlink(url, shortcut) if response['status'] == 'not found'

      response.should include 'url' => url
      response.should include 'shortcut' => shortcut
      response.should include 'owner' => ENV['GOOGLE_SHORT_LINKS_EMAIL']
      response.should include 'is_public' => false
      response.should include 'is_hash' => false

      response = client.get_or_create_shortlink(url, shortcut)

      response.should include 'url' => url
      response.should include 'shortcut' => shortcut
      response.should include 'owner' => ENV['GOOGLE_SHORT_LINKS_EMAIL']
      response.should include 'is_public' => false
      response.should include 'is_hash' => false

      response = client.get_details(shortcut)

      response.should include 'url' => url
      response.should include 'shortcut' => shortcut
      response.should include 'owner' => ENV['GOOGLE_SHORT_LINKS_EMAIL']
      response.should include 'is_public' => false
      response.should include 'is_hash' => false
    end
  end
end
