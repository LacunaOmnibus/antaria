module Antaria

  # Manages a complete empire
  class Empire < LacunaModule

    # Creates a new Empire object. Needs an initialized session object in
    # order to work.
    def initialize(session)
      super session
      @planets = []
    end


    def id
      status['id']
    end


    def name
      status['name']
    end


    def isolationist?
      status['is_isolationist'].to_i == 1
    end


    def tech_level
      status['tech_level']
    end


    def essentia
      status['essentia']
    end


    def home_planet
      home_planet_id = status['home_planet_id']
      planets.select {|p| p.id == home_planet_id }.first
    end


    def planets
      status['planets'].keys.each do |planet_id|
        @planets.push Body.new @session, planet_id
      end if @planets.size != status['planets'].size

      @planets
    end


    # Returns the current user's status message
    def status_message
      status['status_message']
    end


    # Sets a new status message
    def status_message=(msg)
      @session.api_call 'empire', 'set_status_message', msg
    end


    def has_messages?
      status['has_new_messages'].to_i > 0
    end


    def messages
      []
    end
  end
end
