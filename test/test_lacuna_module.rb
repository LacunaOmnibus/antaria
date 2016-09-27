require 'minitest/autorun'

describe Antaria::LacunaModule do
  before do
    @session = Antaria::Session.new(
      'empire_name',
      'empire_password',
      server_uri: 'https://example.com')
    stub_request(:post, /empire\Z/)
      .to_return body: File.new('test/webmock/empire-login-successful.json')
    @module = Antaria::LacunaModule.new @session, explicit_name: 'empire'
  end


  describe "module properties" do
    it "derives the correct module name" do
      m = Antaria::LacunaModule.new nil
      m.module_name.must_equal 'lacunamodule'

      m = Antaria::LacunaModule.new nil, explicit_name: 'foo'
      m.module_name.must_equal 'foo'
    end

    it "derives the correct module path" do
      m = Antaria::LacunaModule.new nil
      m.module_path.must_equal '/lacunamodule'

      m = Antaria::LacunaModule.new nil, explicit_path: '/foo'
      m.module_path.must_equal '/foo'
    end
  end


  describe "basic API calls" do
    it "should supply the correct arguments" do
      session = Minitest::Mock.new
      lacuna_module = Antaria::LacunaModule.new session, explicit_name: 'foo'

      session.expect :game_status, {"foo" => {"id" => "bar"}}
      session.expect :logged_in?, false
      session.expect :login, true
      session.expect :logged_in?, true
      session.expect :game_status, {"foo" => {"id" => "bar"}}
      session.expect :api_call, {}, ['foo', 'tmeth', 'bar', ['param1', 'param2']]
      session.expect :game_status, {"foo" => {"id" => "bar"}}
      session.expect :logged_in?, true
      session.expect :logged_in?, true
      session.expect :game_status, {"foo" => {"id" => "bar"}}
      session.expect :logged_in?, true
      session.expect :game_status, {"foo" => {"id" => "bar"}}
      session.expect :logged_in?, true
      session.expect :game_status, {"foo" => {"id" => "bar"}}

      lacuna_module.api_call 'tmeth', 'param1', 'param2'
      session.verify
    end
  end


  describe "game status" do
    it "automatically logs in" do
      @module.status
      @session.logged_in?.must_equal true
    end

    it "offers the current status" do
      @module.status['name'].must_equal 'Antaria'
    end

    it "retrieves the module ID" do
      @module.id.must_equal "42542"
    end

    it "allows status retrieval using the index operator" do
      @module['name'].must_equal 'Antaria'
    end

    it "allows status retrieval using 'method_missing'" do
      @module.name.must_equal 'Antaria'
    end
  end


  describe "dynamic API calls" do
    it "dynamically does API calls" do
      stub_request(:post, /empire\Z/)
        .to_return(status: 200, body: '{"result": {"foo":"bar"}}')
      @module.foo.must_equal({'foo' => 'bar'})
    end
  end
end
