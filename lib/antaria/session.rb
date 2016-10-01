require 'uri'
require 'json'
require 'date'
require 'net/http'


module Antaria

  ##
  # This class represents a session with the Lacuna Expanse API.
  #
  # The Session class takes care of logging in and out, and offers the primary
  # #api_call primitive that encapsulates formatting and, in general, dealing
  # with the API endpoint.
  class Session

    @@DEFAULT_SERVER_URI = 'https://us1.lacunaexpanse.com'

    attr_reader :rpc_calls
    attr_reader :server_uri
    attr_reader :game_status

    #
    ##
    # Creates a new session with the Lacuna Expanse API.
    #
    # In order to consume the API, the Session object requires an empire name
    # and the corresponding password. By default, it uses
    # +https://us1.lacunaexpanse.com+ as the API base URI, but that can be
    # changed with the optional +server_uri+ parameter.
    #
    # The Session object can optionally yield the Empire object when a block
    # is given, like this:
    #
    #   Session.new 'my_empire', 'my_password' do |empire|
    #     # Work with your empire...
    #   end
    #
    # The advantage of this approach is that #logout is called automatically
    # when the scope of execution leaves the block. Otherwise, you will need
    # to call Session#logout manually.
    def initialize(empire_name, password, server_uri: @@DEFAULT_SERVER_URI)
      @server_uri   = URI(server_uri)
      @empire_name  = empire_name
      @password     = password
      @logged_in    = false
      @session_id   = nil
      @http         = Net::HTTP.new @server_uri.host, @server_uri.port
      @game_status  = {}
      @http.use_ssl = @server_uri.scheme == 'https'

      yield empire and logout if block_given?
    end


    ##
    # Builds the complete URI for a given API module.
    def uri_for(api_module)
      @server_uri + api_module
    end


    ##
    # Executes a call to the API and returns the result.
    #
    # This method is the low-level API call procedure. Given the API module
    # name, a method, and parameters, it encodes these arguments and issues an
    # HTTP POST request to the API endpoint. If a session ID is available,
    # this will be automagically prepended to the arguments. NB. that the
    # Lacuna Expanse API expects the session ID as the first argument to
    # almost all calls, except for the login, so this is the sane default. It
    # can be disabled by supplying +prepend_session_id: false+.
    #
    # After the call has been made, #api_call synchronously waits for
    # the response and returns it. The result of this method call is the +result+
    # key of the returned JSON struct, *not* the whole JSON response.
    #
    # If no explicit login has been performed previously, #api_call will do
    # that implicitly.
    #
    # An API response that includes a +status+ key will update the session's
    # +#game_status+. NB. that it will *update*, not *replace* it.
    #
    # This method will raise an Antaria::APIError exception if the HTTP
    # response code is something other than 200.
    def api_call(api_module, method, *params, prepend_session_id: true)
      id        = "#{api_module}-#{method}-#{DateTime.now.strftime('%s')}"
      http_res  = nil
      api_res   = nil
      retries   = 0

      params.unshift @session_id if @session_id and prepend_session_id

      begin
        http_res = @http.post (uri_for api_module).path, JSON.generate({
            'jsonrpc' => '2.0',
            'id' => id,
            'method' => method,
            'params' => params.flatten
          })

        puts "--\nPOST #{uri_for api_module}::#{method}(#{params.join ', '})" +
          " => #{http_res.body}\n--\n" if $DEBUG

        if '200' == http_res.code then
          api_res = JSON.parse http_res.body, symbolize_names: true
          return api_res[:result] unless api_res[:result].class == Hash

          @session_id = api_res[:result][:session_id] || @session_id

          if api_res[:result][:status]
            @game_status.merge! api_res[:result][:status]
            puts "New game status: #{@game_status}\n--\n" if $DEBUG
          end
        elsif 400 <= http_res.code.to_i
          begin
            # See if we can produce an API error and not just plain HTTP:
            raise Antaria::APIError, http_res
          rescue JSON::ParserError
            raise Antaria::HTTPError, http_res
          end
        end
      rescue Antaria::APIError => e
        # See if our session expired, so that we can login and try again:

        if e.api_code == 1006 && retries.zero?
          retries += 1
          login and retry
        else
          # Sorry, we cannot help:
          raise e
        end
      end

      api_res[:result]
    end


    ##
    # Returns whether a successful login call had been issued previously or
    # not.
    def logged_in?
      @logged_in
    end


    ##
    # Performs a login
    def login
      res = api_call(
        'empire',
        'login',
        @empire_name,
        @password,
        Antaria::API_KEY)
      @logged_in = res[:session_id] != nil
    end


    ##
    # Performs a logout
    def logout
      api_call 'empire', 'logout'
      @logged_in = false
      @session_id = nil
      !@logged_in
    end


    ##
    # Returns a new Empire object that offers access to the actual game object
    # (and all other descendant objects, such as Planets, Ships, etc.)
    def empire
      Empire.new self
    end
  end
end
