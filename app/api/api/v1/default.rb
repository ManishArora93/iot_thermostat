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
            thermostat = Thermostat.where(thermostat_token: thermostat_token).first
            if thermostat.present?
              return thermostat.id 
            else
              error!('Unauthorized. Invalid or expired thermostat token.', 401)
            end
          end

          def generate_next_number_in_sequence
            redis_reading_id_keys = $redis.keys.select {|key| key.starts_with? ("reading_id")}
            if redis_reading_id_keys.present?
              max_id = redis_reading_id_keys.map {|e| e.split("_").last.to_i}.max
            else
              max_id = 0
            end
            max_record_id = Reading.last.present? ? Reading.last.reading_id  : 0
            return max_record_id >= max_id ? max_record_id + 1 : max_id + 1
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
