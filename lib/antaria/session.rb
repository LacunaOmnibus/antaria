require 'uri'
require 'json'
require 'net/http'


module Antaria

  # This class encapsulates the session management of the Lacuna Expanse API
  # service. It does the actual login and logout
  class Session

    attr_reader :server_uri
    attr_reader :session_id
    attr_reader :game_status


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
      @game_status  = {}
      @http.use_ssl = @server_uri.scheme == 'https'
    end


    def uri_for(api_module)
      URI("#{@server_uri}/#{api_module}")
    end


    def api_call(api_module, method, *params, prepend_session_id: true)
      id        = "#{api_module}-#{method}-#{DateTime.now.strftime("%s")}"
      http_res  = nil
      api_res   = nil

      params.unshift @session_id if @session_id and prepend_session_id

      begin
        http_res = @http.post "/#{api_module}", JSON.generate({
            "jsonrpc" => "2.0",
            "id" => id,
            "method" => method,
            "params" => params
          })

        p "#{api_module}/#{method}(#{params}) => HTTP/#{http_res.code} #{http_res.body}"

        if 200 == http_res.code.to_i then
          api_res       = JSON.parse http_res.body
          return api_res['result'] unless api_res['result'].class == Hash

          @session_id   = api_res['result']['session_id'] || @session_id

          if api_res['result']['status'] then
            @game_status.merge! api_res['result']['status']
          end
          p "New game status: #{@game_status}"
        elsif 400 <= http_res.code.to_i then
          begin
            # See if we can produce an API error and not just plain HTTP:
            raise Antaria::APIError.new(http_res)
          rescue JSON::ParserError
            raise Antaria::HTTPError.new(http_res)
          end
        end
      rescue Antaria::APIError => e
        # See if our session expired, so that we can login and try again:

        if e.api_code == 1006 then
          login and retry
        else
          # Sorry, we cannot help:
          raise e
        end
      end

      api_res['result']
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
      @logged_in = res['session_id'] != nil
    end


    def logout
      res = api_call 'empire', 'logout'
      @logged_in  = false
      @session_id = nil
      !@logged_in
    end
  end
end
