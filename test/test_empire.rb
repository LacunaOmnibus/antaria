require 'minitest/autorun'
require 'yaml'
require 'antaria'

describe Antaria::Empire do
  before do
    File.open 'config.yml' do |file|
      @config = YAML.load file.read
    end

    @session = Antaria::Session.new @config['empire'], @config['password']
    @empire  = Antaria::Empire.new @session

    @session.login
  end


  after do
    @session.logout
  end


  describe "when working with the current status" do
    it "must retrieve and set a status message" do
      status_message = @empire.status_message
      status_message.class.must_equal String
      @empire.status_message = "Testing the current API."
      @empire.status_message.must_equal "Testing the current API."
      @empire.status_message = status_message
      @empire.status_message.must_equal status_message
    end

    it "must return a number of planets" do
      @empire.planets.size.must_be :>, 0
      p @empire.planets
    end
  end
end
