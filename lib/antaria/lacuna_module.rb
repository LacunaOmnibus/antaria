module Antaria
  class LacunaModule

    # Initializes this module with the current session
    def initialize(session)
      @session = session
    end

    # Returns the current module's status, as indicated by the current
    # session.
    def status
      unless @session.game_status[modname] then
        return @session.api_call(modname, 'get_status')[modname]
      end

      @session.game_status[modname]
    end


    private


    def modname
      self.class.to_s.downcase.split(/::/).last
    end
  end
end
