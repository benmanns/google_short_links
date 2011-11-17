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
end
