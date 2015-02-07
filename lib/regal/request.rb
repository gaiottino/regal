module Regal
  class Request
    def initialize(env)
      @env = env
    end

    def parameters
      @parameters ||= begin
        path_captures = @env[Route::PATH_CAPTURES_KEY]
        query = Rack::Utils.parse_query(@env[Rack::QUERY_STRING])
        query.merge!(path_captures) if path_captures
        query.freeze
      end
    end

    def headers
      @headers ||= begin
        headers = @env.each_with_object({}) do |(key, value), headers|
          if key.start_with?(HEADER_PREFIX)
            normalized_key = key[HEADER_PREFIX.length, key.length - HEADER_PREFIX.length]
            normalized_key.gsub!(/(?<=^.|_.)[^_]+/) { |str| str.downcase }
            normalized_key.gsub!('_', '-')
          elsif key == CONTENT_LENGTH_KEY
            normalized_key = Rack::CONTENT_LENGTH
          elsif key == CONTENT_TYPE_KEY
            normalized_key = Rack::CONTENT_TYPE
          end
          if normalized_key
            headers[normalized_key] = value
          end
        end
        headers.freeze
      end
    end

    def body
      @env[RACK_INPUT_KEY]
    end

    HEADER_PREFIX = 'HTTP_'.freeze
    CONTENT_LENGTH_KEY = 'CONTENT_LENGTH'.freeze
    CONTENT_TYPE_KEY = 'CONTENT_TYPE'.freeze
    RACK_INPUT_KEY = 'rack.input'.freeze
  end
end