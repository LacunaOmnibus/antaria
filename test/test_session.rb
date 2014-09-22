require 'minitest/autorun'
require 'yaml'
require 'antaria'


describe Antaria::Session do
  before do
    File.open 'config.yml' do |file|
      @config = YAML.load file.read
    end
    @session = Antaria::Session.new @config['empire'], @config['password']
  end

  describe "when asked to log in and out" do
    it "must log in and out again" do
      @session.login.must_equal true
      @session.logged_in?.must_equal true
      @session.logout.must_equal true
      @session.logged_in?.must_equal false
    end
  end
end
