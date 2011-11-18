require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe GoogleShortLinks::Client do
  describe '#initialize' do
    subject { GoogleShortLinks::Client.new @params }

    context 'with options { :server => "a", :secret => "b", :email => "c" }' do
      before :each do
        @params = { :server => 'a', :secret => 'b', :email => 'c' }
      end

      it 'sets server to a' do
        subject.server.should == 'a'
      end

      it 'sets secret to b' do
        subject.secret.should == 'b'
      end

      it 'sets email to c' do
        subject.email.should == 'c'
      end
    end

    context 'with options { :email => "c" }' do
      before :each do
        @params = { :email => 'c' }
      end

      it 'leaves server nil' do
        subject.server.should be_nil
      end

      it 'leaves secret nil' do
        subject.secret.should be_nil
      end

      it 'sets email to c' do
        subject.email.should == 'c'
      end
    end

    context 'with options {}' do
      before :each do
        @params = {}
      end

      it 'leaves server nil' do
        subject.server.should be_nil
      end

      it 'leaves secret nil' do
        subject.secret.should be_nil
      end

      it 'leaves email nil' do
        subject.email.should be_nil
      end
    end
  end

  describe '#get_or_create_hash_url' do
    subject { GoogleShortLinks::Client.new(@options).get_or_create_hash_url(@url, @params) }

    context 'at 2011-11-17 13:04:15 -0500' do
      before :each do
        @now = Time.at(1321553055)
        Timecop.freeze(@now)
      end

      after :each do
        Timecop.return
      end

      context 'with server a, secret b, and email c' do
        before :each do
          @options = { :server => 'a', :secret => 'b', :email => 'c' }
        end

        context 'with url d' do
          before :each do
            @url = 'd'
          end

          context 'with empty params' do
            before :each do
              @params = {}
            end

            it 'should return a url with host a, path get_or_create_hash, signature method HMAC-SHA1, a current timestamp, url d, and user c, that is signed' do
              subject.should == "http://a/js/get_or_create_hash?oauth_signature_method=HMAC-SHA1&timestamp=#{Time.now.to_f}&url=d&user=c&oauth_signature=H8ugo%2B8%2FHLIORPo9LjntVSClZXY%3D"
            end
          end

          context 'with params oauth_signature_method HMAC-MD5, blah 123' do
            before :each do
              @params = { :oauth_signature_method => 'HMAC-MD5', :blah => 123 }
            end

            it 'should return a url with host a, path get_or_create_hash, signature method HMAC-MD5, a current timestamp, url d, user c, and extra parameter blah 123, that is signed' do
              subject.should == "http://a/js/get_or_create_hash?blah=123&oauth_signature_method=HMAC-MD5&timestamp=#{Time.now.to_f}&url=d&user=c&oauth_signature=SHidraLOaaGtSP08qTXITZRk4nk%3D"
            end
          end
        end
      end
    end
  end

  describe '#get_or_create_shortlink_url' do
    subject { GoogleShortLinks::Client.new(@options).get_or_create_shortlink_url(@url, @shortcut, @params) }

    context 'at 2011-11-17 13:04:15 -0500' do
      before :each do
        @now = Time.at(1321553055)
        Timecop.freeze(@now)
      end

      after :each do
        Timecop.return
      end

      context 'with server a, secret b, and email c' do
        before :each do
          @options = { :server => 'a', :secret => 'b', :email => 'c' }
        end

        context 'with url d' do
          before :each do
            @url = 'd'
          end

          context 'with a shortcut e' do
            before :each do
              @shortcut = 'e'
            end

            context 'with empty params' do
              before :each do
                @params = {}
              end

              it 'should return a url with host a, path get_or_create_shortlink, signature method HMAC-SHA1, shortcut e, a current timestamp, url d, and user c, that is signed' do
                subject.should == "http://a/js/get_or_create_shortlink?oauth_signature_method=HMAC-SHA1&shortcut=e&timestamp=#{Time.now.to_f}&url=d&user=c&oauth_signature=Hf23Wj%2FoHARH4oyqy7FCgzUQrSk%3D"
              end
            end

            context 'with params oauth_signature_method HMAC-MD5, blah 123' do
              before :each do
                @params = { :oauth_signature_method => 'HMAC-MD5', :blah => 123 }
              end

              it 'should return a url with host a, path get_or_create_shortlink, signature method HMAC-MD5, shortcut e, a current timestamp, url d, user c, and extra parameter blah 123, that is signed' do
                subject.should == "http://a/js/get_or_create_shortlink?blah=123&oauth_signature_method=HMAC-MD5&shortcut=e&timestamp=#{Time.now.to_f}&url=d&user=c&oauth_signature=bdfkqZPbuqsKqalwou08oImutV0%3D"
              end
            end
          end
        end
      end
    end
  end
end
