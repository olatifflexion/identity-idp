require_relative '../../service'

module InheritedProofing
  module Va
    module UserAttributes
      class UserAttributesService < InheritedProofing::Service
        def initialize
        end

        # Instantiates a Request object, calls the endpont,
        # and returns a Response object.
        def execute
          raise NotImplementedError
        end
      end
    end
  end
end
