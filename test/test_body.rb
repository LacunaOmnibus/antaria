require 'minitest/autorun'
require 'antaria'


describe Antaria::Body do
  before do
    stub_request(:post, /empire\Z/)
      .with(body: /login/)
      .to_return(body: File.new('test/webmock/empire-login-successful.json'))
    stub_request(:post, /body\Z/)
      .with(body: /get_status/)
      .to_return(body: File.new('test/webmock/body-get_status.json'))
    stub_request(:post, /body\Z/)
      .with(body: /get_buildings/)
      .to_return(body: File.new('test/webmock/body-get_buildings.json'))
    stub_request(:post, /orestorage\Z/)
      .with(body: /view/)
      .to_return(body: File.new('test/webmock/orestorage-view.json'))
    stub_request(:post, /foodreserve\Z/)
      .with(body: /view/)
      .to_return(body: File.new('test/webmock/foodreserve-view.json'))

    @session = Antaria::Session.new(
      'empire_name',
      'empire_password',
      server_uri: 'https://example.com')
    @body  = @session.empire.home_planet
  end

  describe "resources" do
    it "has the current resource rates" do
      @body.resource_rates.ore.must_equal 254514512
      @body.resource_rates.water.must_equal 326564199
      @body.resource_rates.energy.must_equal 407751561
      @body.resource_rates.food.must_equal 332307944
      @body.resource_rates.waste.must_equal 2639745
    end

    it "fetches the current stored resources" do
      @body.resources_available.water.must_equal 24945406925
      @body.resources_available.energy.must_equal 24945406925
      @body.resources_available.food.must_equal 24945406925
      @body.resources_available.waste.must_equal 7821204973
      @body.resources_available.ore.must_equal 24945406925
    end

    it "fetches the different ore types stored" do
      expected_ores = {
        chromite: 1752459112,
         monazite: 3833800932,
         anthracite: 2136211653,
         halite: 734532679,
         rutile: 780977788,
         chalcopyrite: 1475978870,
         magnetite: 1067429039,
         trona: 1329532845,
         zircon: 748187836,
         gold: 1189107674,
         fluorite: 1825599264,
         goethite: 1376252636,
         sulfur: 1298819868,
         methane: 723014117,
         beryl: 734731556,
         bauxite: 907161705,
         kerogen: 801594348,
         uraninite: 1630117095,
         gypsum: 1162847453,
         galena: 813348767
      }
      actual_ores = @body.resources_available.ores

      actual_ores.members.each do |ore_type|
        actual_ores[ore_type].must_equal expected_ores[ore_type]
      end
    end

    it "fetches the different food types stored" do
      expected_foods = {
        burger: 957775892,
        potato: 720637674,
        bean: 720644686,
        meal: 1007157093,
        bread: 1007151357,
        cider: 720626644,
        beetle: 720640837,
        wheat: 1069242412,
        cheese: 720639154,
        lapis: 4859806673,
        chip: 720627684,
        corn: 1069243517,
        syrup: 1007150430,
        fungus: 3063047373,
        shake: 720632592,
        root: 720635571,
        pie: 1007145842,
        algae: 2626343197,
        milk: 720628614,
        apple: 720657579,
        pancake: 720634386,
        soup: 720636030
      }
      actual_foods =  @body.resources_available.foods

      actual_foods.members.each do |type|
        actual_foods[type].must_equal expected_foods[type]
      end
    end
  end

  describe "buildings" do
    it "retrieves all buildings" do

      @body.buildings.size.must_equal 70
    end
  end
end
