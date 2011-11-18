require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe GoogleShortLinks::Parser do
  subject { GoogleShortLinks::Parser }

  it { should <= HTTParty::Parser }

  it('should support format :json') { should be_supports_format :json }

  describe '#call' do
    subject { GoogleShortLinks::Parser.call @body, @format }

    context 'with a format of :json' do
      before :each do
        @format = :json
      end

      context 'with an body of {"a":"b"}' do
        before :each do
          @body = '{"a":"b"}'
        end

        it { should == {'a' => 'b'} }
      end
    end
  end
end
