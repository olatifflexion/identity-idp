# Encapsulates request, response, error handling, validation, etc.
module InheritedProofing
  class Service
    def initialize
    end

    # Instantiates a Request object, calls the endpont,
    # and returns a Response object.
    def execute
      raise NotImplementedError
    end
  end
end
