module Antaria
  class Building < LacunaModule


    ##
    # Creates a new Building object given an initial status
    #
    # The Building object is usually created by the #Body.buildings factory
    # method. The Lacuna Expanse API offers buildings only as part of the
    # +get_buildings+ API call, which is part of the +Body+ module. The result
    # of this call supplies the current status for each building, which
    # includes its ID and the corresponding API url, hence this
    # data is mandatory for the creation of the Building object.
    #
    # +session+:: The session object
    # +id+:: The building's ID
    # +initial_status+:: The building's initial status
    def initialize(session, id, initial_status)
      super session, status: initial_status.merge({ "id" => id })
    end


    ##
    # Returns the API path for the building object
    def module_path
      status[:url]
    end


    ##
    # Returns 'building' for objects of this class an all inheriting ones.
    def module_name
      "building"
    end


    ##
    # Returns the name of the building-specific module
    def building_module_name
      status[:name].delete ' '
    end


    ##
    # Get all properties of the building.
    #
    # The +view+ Lacuna Expanse API function can additionally return objects
    # referenced by keys other than the +building+ and +status+. 
    #def view
    #  p module_path
    #  require 'pp'; pp api_call 'view'
    #  #api_call 'view'
    #end


    ##
    # Returns true iff the building is currently upgrading or repairing.
    def pending_build?
      status.has_key? 'pending_build'
    end
  end
end
