module Antaria

  ##
  # This abstract base class is the home to all information and methods common
  # to all Lacuna API modules. It contains the methods for making API calls
  # for modules, and updates the module's status as appropriate.
  class LacunaModule

    ##
    # Initializes this module with the current session.
    #
    # The LacunaModule class constructor offers a number of additional
    # arguments.
    #
    # +status+:: Sets an initial game status. The default is an empty Hash.
    # +explicit_name+:: Overwrites the default-derived module name, which is the
    #   current class name.
    # +explicit_path+:: Explicitly sets the module path for the API URI, which
    #   is normally +"/{module_name}"+.
    def initialize(session, status: {}, explicit_name: nil, explicit_path: nil)
      @status = status
      @session = session
      @explicit_module_name = explicit_name
      @explicit_module_path = explicit_path
    end


    ##
    # Returns the path of the module below the API server. E.g., if the API
    # server is +https://us1.lacunaexpanse.com+, this method might return
    # +/body+ for the Body module. Usually, this is just the name of the
    # module.
    #
    # Module where the name of the class maps not to the #module_name will
    # need to overwrite this method.
    def module_path
      if @explicit_module_path
        return @explicit_module_path
      else
        return "/#{module_name}"
      end
    end


    ##
    # Returns the name of the module in the lacuna API. Usually, this is the
    # name of the class.
    def module_name
      if @explicit_module_name
        return @explicit_module_name
      else
        return self.class.to_s.split(/::/).last.downcase
      end
    end


    ##
    # Retrieves the ID of the current object. It does so by looking up
    # +status('id')+ under the following two assumptions:
    #
    # * The object's ID is returned via the +result+ hash or is part of the
    #   +status[module_name]+ hash
    # * The ID is referenced by the +"id"+ string key.
    #
    # If this is not the case for a module, the descendant class must
    # reimplement this method.
    def id
      status['id']
    end


    ##
    # Returns the current game status that was returned since the last
    # successful API call.
    #
    # This method will not result in a call to any +get_status+ or +view+ 
    # API endpoint.
    #
    # *Note:* Calling this method will trigger the session login, if not 
    # already done.
    def status
      unless @session.logged_in?
        @session.login
        update_status
      end

      @status
    end


    ##
    # The index operator is a convencience access method for the module's
    # current game status as returned by #status. It allows the usage of
    # symbols, even though the Lacuna API returns string keys.
    def [](index)
      status[index]
    end


    ##
    # Using the #method_missing function, any LacunaModule is able to infer
    # look-up of status variables or perform an API call. It does so by
    # applying the following rules:
    #
    # 1. If +symbol+ denotes a valid key in #status, it is returned
    # 2. else, an API call is made.
    def method_missing(symbol, *args, &block)
      symbol = symbol.to_s

      if status.has_key? symbol then
        return status[symbol]
      else
        return api_call symbol, args
      end
    end


    ##
    # A shorthand for +@session.api_call module_name, method, id, args+ 
    # with automatic status merging.
    #
    # This version of #api_call behaves calls Antaria::Session#api_call. It
    # prepends the module name as returned by #module_name automatically. It
    # also checks the current game status hash of the session: If contains 
    # a key equal to the module's name and this hash has an +id+ key that
    # equals what #id returns, the module object's status is updated.
    def api_call(method, *args)
      result = @session.api_call module_name, method, id, args
      update_status
      return result
    end


    private


    def update_status
      if @session.game_status[module_name] && (!id ||
            id && @session.game_status[module_name][id] == id)
        @status.merge! @session.game_status[module_name]
      end
    end
  end
end
