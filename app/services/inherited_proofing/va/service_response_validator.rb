module InheritedProofing
  module Va
    # Validates the response returned from the inherited proofing service.
    class ServiceResponseValidator
      REQUIRED_FIELDS = %i[field_0 field_1].freeze

      attr_reader :response

      def initialize(response)
        @response = response
      end

      def validate!
        raise 'Service response is nil' if response.nil?

        validate_fields!
        validate_field_data!
      end

      private

      def validate_fields!
        return if REQUIRED_FIELDS.all? { |key| response.key? key }

        raise "Service response object did not contain one or more of the expected required fields: #{REQUIRED_FIELDS}."
      end

      def validate_field_data!
        # TODO: Iterate and validate date for each field.

        field = REQUIRED_FIELDS.first
        message = 'not a valid <data_type>'

        raise "Service response object data for field '#{field}' is invalid: #{message}."
      end
    end
  end
end
