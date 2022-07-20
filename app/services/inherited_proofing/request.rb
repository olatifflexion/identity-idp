# Represents a request to an endpoint.
module InheritedProofing
  class Request
    attr_reader :endpoint, :options

    def initialize(endpoint:, options: {})
      @endpoint = endpoint
      @options = options
    end

    # Call the end point, and return a Response object.
    def call
      raise NotImplementedError
    end

    def uri
      base_uri + endpoint
    end

    private

    attr_writer :endpoint, :options

    def base_uri
      raise NotImplementedError
    end
  end
end
