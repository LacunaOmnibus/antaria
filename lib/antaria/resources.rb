module Antaria
  class Resources
    Ores = Struct.new(
        :chromite, 
        :monazite, 
        :anthracite, 
        :halite, 
        :rutile, 
        :chalcopyrite, 
        :magnetite, 
        :trona, 
        :zircon, 
        :gold, 
        :fluorite, 
        :goethite, 
        :sulfur, 
        :methane, 
        :beryl, 
        :bauxite, 
        :kerogen, 
        :uraninite, 
        :gypsum, 
        :galena) do
      def [](member)
        super || 0
      end
    end 


    Foods = Struct.new(
        :burger,
        :potato,
        :bean,
        :meal,
        :bread,
        :cider,
        :beetle,
        :wheat,
        :cheese,
        :lapis,
        :chip,
        :corn,
        :syrup,
        :fungus,
        :shake,
        :root,
        :pie,
        :algae,
        :milk,
        :apple,
        :pancake,
        :soup) do
      def [](member)
        super || 0
      end
    end 


    attr_accessor :ore
    attr_accessor :ores
    attr_accessor :food
    attr_accessor :foods
    attr_accessor :water
    attr_accessor :waste
    attr_accessor :energy
    attr_accessor :glyphs


    def initialize
      @ores = Ores.new
      @foods = Foods.new
      @glyphs = []
      @ore = @food = @water = @waste = @energy = 0
    end
  end
end
