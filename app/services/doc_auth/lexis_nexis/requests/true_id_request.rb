module DocAuth
  module LexisNexis
    module Requests
      class TrueIdRequest < DocAuth::LexisNexis::Request
        attr_reader :front_image, :back_image, :selfie_image, :liveness_checking_enabled

        def initialize(
          config:,
          user_uuid:,
          uuid_prefix:,
          front_image:,
          back_image:,
          selfie_image: nil,
          liveness_checking_enabled: nil,
          image_source: nil
        )
          super(config: config, user_uuid: user_uuid, uuid_prefix: uuid_prefix)
          @front_image = front_image
          @back_image = back_image
          @selfie_image = selfie_image
          @liveness_checking_enabled = liveness_checking_enabled
          @image_source = image_source
        end

        private

        def body
          document = {
            Document: {
              Front: encode(front_image),
              Back: encode(back_image),
              DocumentType: 'DriversLicense',
            },
          }

          document[:Document][:Selfie] = encode(selfie_image) if liveness_checking_enabled

          settings.merge(document).to_json
        end

        def handle_http_response(http_response)
          return handle_passthrough_response(http_response) if /Passthrough/.match?(workflow)

          LexisNexis::Responses::TrueIdResponse.new(
            http_response,
            liveness_checking_enabled,
            config,
          )
        end

        def handle_passthrough_response(http_response)
          LexisNexis::Responses::TrueIdPassthroughResponse.new(
            http_response,
            liveness_checking_enabled,
            config,
          )
        end

        def method
          :post
        end

        def account_id
          config.trueid_account_id
        end

        def username
          config.trueid_username
        end

        def password
          config.trueid_password
        end

        def workflow
          return liveness_workflow if liveness_checking_enabled
          noliveness_workflow
        end

        def liveness_workflow
          return config.trueid_liveness_nocropping_workflow if acuant_sdk_source?
          config.trueid_liveness_cropping_workflow
        end

        def noliveness_workflow
          return config.trueid_noliveness_nocropping_workflow if acuant_sdk_source?
          config.trueid_noliveness_cropping_workflow
        end

        def acuant_sdk_source?
          @image_source == ImageSources::ACUANT_SDK
        end

        def encode(image)
          Base64.strict_encode64(image)
        end

        def metric_name
          'lexis_nexis_doc_auth_true_id'
        end

        def timeout
          IdentityConfig.store.lexisnexis_trueid_timeout
        end
      end
    end
  end
end
