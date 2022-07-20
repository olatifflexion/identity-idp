module InheritedProofing
  module Va
    # Encapsulates request, response, error handling, validation, etc. for calling
    # the VA service to gain PII for a particular user that will be subsequently
    # used to proof the user using inherited proofing.
    class Service
      REQUEST_URI = 'https://staging-api.va.gov/inherited_proofing/user_attributes'.freeze

      attr_reader :auth_code

      def initialize(auth_code)
        @auth_code = auth_code
      end

      # Calls the endpoint and returns the decrypted response.
      def execute
        response = Net::HTTP.get_response(request_uri, request_headers)
        decrypt_payload(response)
      end

      private

      def request_uri
        @request_uri ||= URI REQUEST_URI
      end

      def request_headers
        { Authorization: "Bearer #{jwt_token}" }
      end

      def jwt_token
        JWT.encode(jwt_payload, private_key, jwt_encryption)
      end

      def jwt_payload
        { inherited_proofing_auth: auth_code, exp: jwt_expires }
      end

      def private_key
        @private_key ||= AppArtifacts.store.oidc_private_key
      end

      def jwt_encryption
        'RS256'
      end

      def jwt_expires
        1.day.from_now.to_i
      end

      def decrypt_payload(response)
        payload = JSON.parse(response.body)['data']
        JWE.decrypt(payload, private_key) if payload
      end
    end
  end
end
