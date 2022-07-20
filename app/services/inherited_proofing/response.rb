# Represents a response from an endpoint
module InheritedProofing
  class Response
    attr_reader :response

    def initialize(response)
      @response = response
    end

    private

    attr_writer :response
  end
end
