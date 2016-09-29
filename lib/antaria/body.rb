module Antaria

  # A stellar body, planet or asteroid.
  class Body < LacunaModule

    # Create a new Body object by giving it the actual session object as well
    # as its current (i.e., initial) status. The Body object will then
    # maintain its own status.
    def initialize(session, status)
      super session, status: status

      # Make sure we've got the full status:

      result = api_call 'get_status'
      status.merge! result['body']
    end


    def id
      @status['id'].to_i
    end


    def star_id
      @status['star_id'].to_i
    end


    def orbit
      @status['orbit'].to_i
    end


    def size
      @status['size'].to_i
    end


    # Returns the hourly resource rates of the body
    def resource_rates
      rates = Antaria::Resources.new
      rates.ores.members.each do |ore_type|
        value = @status['ore'][ore_type.to_s].to_i || 0
        rates.ores.send "#{ore_type.to_s}=", value
      end

      rates.ore = @status['ore_hour'].to_i
      rates.food = @status['food_hour'].to_i
      rates.water = @status['water_hour'].to_i
      rates.waste = @status['waste_hour'].to_i
      rates.energy = @status['energy_hour'].to_i

      rates  
    end


    def resources_available
      stored = Antaria::Resources.new
      stored.ore = @status['ore_stored'].to_i
      stored.food = @status['food_stored'].to_i
      stored.water = @status['water_stored'].to_i
      stored.waste = @status['waste_stored'].to_i
      stored.energy = @status['energy_stored'].to_i

      # Different ore and food types are available via the 
      # corresponding buildings:

      buildings.select do |b|
        b.building_module_name.match(/OreStorage/)
      end.each do |store|
        store.view['ore_stored'].each_pair do |type, amount|
          stored.ores[type.to_sym] += amount.to_i
        end
      end

      # We do the same for the different types of food:

      buildings.select do |b|
        b.building_module_name.match(/FoodReserve/)
      end.each do |store|
        store.view['food_stored'].each_pair do |type, amount|
          stored.foods[type.to_sym] += amount.to_i
        end
      end

      stored 
    end


    ##
    # Compares a Body to another one by comparing their respective +star_id+
    # properties.
    def ==(other)
      other.class == self.class and self.star_id == other.star_id
    end


    ##
    # Fetches all buildings on the particular body
    def buildings
      api_call('get_buildings')['buildings'].to_a.map do |i|
        Building.new(@session, i[0].to_i, i[1])
      end
    end
  end
end
