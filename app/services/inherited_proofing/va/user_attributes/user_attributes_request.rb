require_relative '../../request'

module InheritedProofing
  module Va
    module UserAttributes
      class UserAttributesRequest < InheritedProofing::Request
        # Make the call
        def call
          raise NotImplementedError
        end
      end
    end
  end
end
