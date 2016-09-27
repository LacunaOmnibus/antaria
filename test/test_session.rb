require 'json'
require 'minitest/autorun'


describe Antaria::Session do
  before do
    @session = Antaria::Session.new(
      'empire_name',
      'empire_password',
      server_uri: 'https://example.com')
  end

  describe "uri_for" do
    it "must build the corrent module URI" do
      @session.uri_for('mod').must_equal URI('https://example.com/mod')
    end
  end

  describe "when asked to log in and out" do
    it "must log in" do
      stub_request(:post, /empire\Z/)
        .to_return body: File.new('test/webmock/empire-login-successful.json')

      @session.login.must_equal true
      @session.logged_in?.must_equal true

      assert_requested :post, "https://example.com/empire",
        body: /method.*?login/
    end

    it "must log in automagically" do
      stub_request(:post, /foo\Z/)
        .to_return(status: 404, body: {'error' => {'code' => 1006}}.to_json)
        .to_return(status: 200, body: '{ }')
      stub_request(:post, /empire\Z/)
        .to_return body: File.new('test/webmock/empire-login-successful.json')
      @session.logged_in?.must_equal false
      @session.api_call 'foo', 'bar', %w[baz, quux]
      @session.logged_in?.must_equal true
      assert_requested :post, /empire\Z/,
        body: /method.*?login/
    end

    it "must log out" do
      stub_request(:post, /empire\Z/)
        .to_return body: File.new('test/webmock/empire-login-successful.json')

      @session.login
      @session.logout

      stub_request(:post, /empire\Z/)
        .with(body: /method\":\"logout/)
        .to_return(status: 200, body: "", headers: {})
      assert_requested :post, "https://example.com/empire",
        body: /method.*?logout/
    end
  end

  describe "it offers a game object" do
    it "returns an initialized Empire object" do
      stub_request(:post, /empire\Z/)
        .to_return body: File.new('test/webmock/empire-login-successful.json')
      e = @session.empire
      e.name.must_equal 'Antaria'
    end
  end
end
