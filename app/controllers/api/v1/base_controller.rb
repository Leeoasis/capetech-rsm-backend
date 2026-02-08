module Api
  module V1
    class BaseController < ApplicationController
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
      rescue_from ActionController::ParameterMissing, with: :parameter_missing

      private

      def record_not_found(exception)
        render json: {
          error: {
            message: exception.message,
            details: {}
          }
        }, status: :not_found
      end

      def record_invalid(exception)
        render json: {
          error: {
            message: 'Validation failed',
            details: exception.record.errors.messages
          }
        }, status: :unprocessable_entity
      end

      def parameter_missing(exception)
        render json: {
          error: {
            message: exception.message,
            details: {}
          }
        }, status: :bad_request
      end

      def render_error(message, status: :unprocessable_entity, details: {})
        render json: {
          error: {
            message: message,
            details: details
          }
        }, status: status
      end

      def pagination_metadata(collection)
        {
          current_page: collection.current_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count,
          per_page: collection.limit_value
        }
      end
    end
  end
end
