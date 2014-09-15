require 'json'


module Antaria
  class Error < Exception
  end

  
  class HTTPError < Error
    attr_reader :http_response

    def initialize(http_response)
      @http_response = http_response
    end


    def http_code
      @http_response.code
    end


    def http_body
      @http_response.body
    end
  end


  class APIError < HTTPError
    attr_reader :api_error_hash

    def initialize(http_response)
      super http_response
      @api_error_hash = JSON.parse http_body
    end


    def api_code
      @api_error_hash['error']['code']
    end


    def api_message
      @api_error_hash['error']['message']
    end


    def call_id
      @api_error_hash['id']
    end
  end
end
