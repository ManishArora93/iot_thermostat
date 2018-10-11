module API  
  module V1
    module Default
      extend ActiveSupport::Concern

      included do
        prefix "api"
        version "v1", using: :path
        default_format :json
        format :json
        formatter :json, 
            Grape::Formatter::ActiveModelSerializers

        helpers do
          def permitted_params
            @permitted_params ||= declared(params, include_missing: false)
          end

          def logger
            Rails.logger
          end

          def api_response response
            case response
            when Integer
              status response
            when String
              response
            when Hash
              response
            when Net::HTTPResponse
              "#{response.code}: #{response.message}"
            else
              status 400 # Bad request
            end
          end

          def authenticate_thermostat(thermostat_token)
            p "thermostat_token #{thermostat_token}"
            thermostat = Thermostat.where(thermostat_token: thermostat_token).first
            if thermostat.present?
              return thermostat.id 
            else
              error!('Unauthorized. Invalid or expired thermostat token.', 401)
            end
          end

          def generate_next_number_in_sequence
            last_number = Reading.last.present? ? Reading.last.reading_id + 1 : 1
          end

          def clean_params(params)
            ActionController::Parameters.new(params)
          end
        end

        rescue_from ActiveRecord::RecordNotFound do |e|
          error_response(message: e.message, status: 404)
        end

        rescue_from ActiveRecord::RecordInvalid do |e|
          error_response(message: e.message, status: 422)
        end
      end
    end
  end
end  
