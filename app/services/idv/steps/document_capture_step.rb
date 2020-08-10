module Idv
  module Steps
    class DocumentCaptureStep < DocAuthBaseStep
      def call
        api_upload = flow_session['api_upload']
        response = (api_upload && api_upload['documents']) || post_form_images
        handle_response(response)
      end

      private

      def post_form_images
        selfie = selfie_image ? selfie_image.read : nil
        post_images(front_image.read, back_image.read, selfie)
      end

      def handle_response(response)
        if response.to_h[:success]
          save_proofing_components
          extract_pii_from_doc(response) unless flow_session[:pii_from_doc]
          response
        else
          handle_document_verification_failure(response)
        end
      end

      def handle_document_verification_failure(response)
        mark_step_incomplete(:document_capture)
        notice = if liveness_checking_enabled?
                   { notice: I18n.t('errors.doc_auth.document_capture_info_with_selfie_html') }
                 else
                   { notice: I18n.t('errors.doc_auth.document_capture_info_html') }
                 end
        extra = response.to_h.merge(notice)
        failure(response.errors.first, extra)
      end

      def form_submit
        Idv::DocumentCaptureForm.
          new(liveness_checking_enabled: liveness_checking_enabled?).
          submit(permit(:front_image,  :front_image_data_url,
                        :back_image,   :back_image_data_url,
                        :selfie_image, :selfie_image_data_url))
      end
    end
  end
end
