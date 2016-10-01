module Antaria

  # Manages a complete empire
  class Empire < LacunaModule

    # Creates a new Empire object. Needs an initialized session object in
    # order to work.
    def initialize(session)
      super session
      @bodies = []
    end


    def isolationist?
      status[:is_isolationist] == '1'
    end


    def home_planet
      home_planet_id = status[:home_planet_id].to_i
      bodies.find {|p| p.id == home_planet_id }
    end


    def bodies
      colonies_data = status[:bodies][:colonies]
      if @bodies.size != colonies_data.size then
        @bodies = colonies_data.map do |body|
          Body.new @session, body
        end
      end

      @bodies
    end


    # Returns the current user's status message
    def status_message
      status[:status_message]
    end


    # Sets a new status message
    def status_message=(msg)
      result = api_call 'set_status_message', msg

      @session.game_status[:empire].merge! result[:empire]
      @status.merge! result[:empire]
      
      status[:status_message]
    end


    # Indicates that new, i.e., unread messages are available.
    def new_messages?
      status[:has_new_messages].to_i > 0
    end
  end
end
