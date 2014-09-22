module Antaria

  # A stellar body, planet or asteroid.
  class Body < LacunaModule

    # This body's ID
    attr_reader :id

    # The body's [x, y] coordinates
    attr_reader :coordinates


    def initialize(session, body_id)
      super session
      @id = body_id
    end


    def star_name
      status['star_name']
    end


    def name
      status['name']
    end


    def orbit
      status['orbit']
    end


    def type
      status['type']
    end


    # Gets all buildings on that particular body
    def buildings
      []
    end
  end
end
