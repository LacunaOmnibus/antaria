require 'minitest/autorun'
require 'antaria'


describe Antaria::Empire do
  before do
    @session = Antaria::Session.new(
      'empire_name',
      'empire_password',
      server_uri: 'https://example.com')
    stub_request(:post, /empire\Z/)
      .to_return body: File.new('test/webmock/empire-login-successful.json')
    @empire  = @session.empire
  end


  describe 'module structure' do
    it 'must have the correct API module name' do
      @empire.module_name.must_equal 'empire'
    end
  end


  describe 'querying basic properties' do
    it "must retrieve ID and empire name" do
      @empire.id.must_equal '42542'
      @empire.name.must_equal 'Antaria'
    end

    it "must indicate new messages" do
      @empire.new_messages?.must_equal true
    end

    it "must return the current essentia balance" do
      @empire.essentia.must_equal 0.8
    end
  end


  describe "colonies and bodies" do
    it "must return the planets" do
      stub_request(:post, /body\Z/)
        .to_return(body: File.new('test/webmock/body-get_status.json'))
      @empire.bodies.size.must_be :>, 0
      @empire.bodies.include?(@empire.home_planet).must_equal true
    end
  end


  describe "status message" do
    it "must retrieve a status message" do
      status_message = @empire.status_message
      status_message.class.must_equal String
      @empire.status_message.must_equal "Testing the current API."
    end

    it "must set a new status message" do 
      @empire.login

      stub_request(:post, /empire\Z/)
        .with(body: /set_status_message/)
        .to_return(status: 200, body: File.new(
          'test/webmock/empire-new-status-message.json'))
      status_message = 'Test New Status Message'
      @empire.status_message = status_message
      @empire.status_message.must_equal status_message
    end
  end
end
