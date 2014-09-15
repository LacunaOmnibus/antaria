module Antaria

  # Manages a complete empire
  class Empire

    # Creates a new Empire object. Needs an initialized session object in
    # order to work.
    def initialize(session)
      @session = session
    end


    def status
      unless @session.status
        @session.api_call 'empire', 'get_status'
      end

      @session.status['empire']
    end


    def name
      status['name']
    end


    def isolationist?
      status['is_isolationist'].to_i == 1
    end


    def home_planet
      status['planets'][status['home_planet_id']]
    end


    def planets
      status['planets']
    end

    
    # Returns the current user's status message
    def status_message
      status['status_message']
    end


    # Sets a new status message
    def status_message=(msg)
      @session.api_call 'empire', 'set_status_message', @session.session_id, msg
    end
  end
end
