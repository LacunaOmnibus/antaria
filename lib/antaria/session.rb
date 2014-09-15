require 'uri'
require 'json'


module Antaria

  # This class encapsulates the session management of the Lacuna Expanse API
  # service. It does the actual login and logout
  class Session

    attr_reader :server_uri
    attr_reader :session_id
    attr_reader :last_answer


    def initialize(
        empire_name,
        password,
        server_uri: 'https://us1.lacunaexpanse.com')
      @server_uri   = URI(server_uri)
      @empire_name  = empire_name
      @password     = password
      @logged_in    = false
      @session_id   = nil
      @http         = Net::HTTP.new @server_uri.host, @server_uri.port
      @rpc_calls    = 0
      @last_answer  = {}

      @http.use_ssl = @server_uri.scheme == 'https'
    end


    def uri_for(api_module)
      URI("#{@server_uri}/#{api_module}")
    end


    # Short-cut access to last call's "result" field. May be nil if there was
    # no call or if the call did not return a "result" (i.e., an error)
    def last_result
      @last_answer['result']
    end


    # Short-cut access to last call's result/status field. May be nil (or even
    # throw an exception) if the last call did not return a status object,
    # e.g. because of an error, or if there hasn't yet been any API call made.
    def status
      @last_answer['result']['status']
    end


    def api_call(api_module, method, *params, prepend_session_id: true)
      id = "#{api_module}-#{method}-#{@rpc_calls}"
      @rpc_calls += 1

      params.push @session_id if @session_id and prepend_session_id

      http_res = nil
      
      begin
        http_res = @http.post "/#{api_module}", JSON.generate({
            "jsonrpc" => "2.0",
            "id" => id,
            "method" => method,
            "params" => params
          })

        if 200 == http_res.code.to_i then
          @last_answer = JSON.parse http_res.body
          @session_id = @last_answer['result']['session_id']
        elsif 400 <= http_res.code.to_i then
          begin
            # See if we can produce an API error and not just plan HTTP:
            raise Antaria::APIError.new(http_res)
          rescue JSON::ParserError
            raise Antaria::HTTPError.new(http_res)
          end
        end
      rescue Antaria::APIError => e
        # See if our session expired, so that we can login and try again:

        if e.api_code == '1006' then
          login and retry
        else
          # Sorry, we cannot help:
          raise e
        end
      end

      @last_answer
    end


    def logged_in?
      @logged_in
    end


    def login
      res = api_call(
          'empire',
          'login',
          @empire_name,
          @password,
          Antaria::API_KEY)
      @logged_in = res['result']['session_id'] != nil
    end


    def logout
      res = api_call 'empire', 'logout', @session_id
      @logged_in = !(@last_answer['error'])
      !@logged_in
    end
  end
end
