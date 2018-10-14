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

          def logger
            Rails.logger
          end

          def authenticate_thermostat(thermostat_token)
            thermostat = Thermostat.where(thermostat_token: thermostat_token).first
            if thermostat.present?
              return thermostat.id 
            else
              error!(status: "401", message: 'Unauthorized. Invalid or expired thermostat token.')
            end
          end

          def generate_next_number_in_sequence(thermostat_id)
            thermostat_data = $redis.get("thermostat_id_#{thermostat_id}_stats")
            if thermostat_data.present?
              max_id = JSON.parse(thermostat_data)['counter']
            else
              max_id = 0
            end
            max_record_id = Reading.where(thermostat_id: thermostat_id).present? ? Reading.where(thermostat_id: thermostat_id).last.reading_id  : 0
            return max_record_id >= max_id ? max_record_id + 1 : max_id + 1
          end

          def calculate_thermostat_stats(thermostat_id, temperature, humidity, battery_charge)
            thermostat_data = $redis.get("thermostat_id_#{thermostat_id}_stats")
            if thermostat_data.present?
              stats = JSON.parse(thermostat_data)
              counter = stats['counter']
              temp_avg = ( ( stats['temperature']['avg'].to_f * counter) + temperature.to_i ) / (counter+1)
              temp_min = (stats['temperature']['min'].to_i <= temperature.to_i) ? stats['temperature']['min'].to_i : temperature.to_i
              temp_max = (stats['temperature']['max'].to_i >= temperature.to_i) ? stats['temperature']['max'].to_i : temperature.to_i
              hum_avg = ( ( stats['humidity']['avg'].to_f * counter) + humidity.to_i ) / (counter+1)
              hum_min = (stats['humidity']['min'].to_i <= humidity.to_i) ? stats['humidity']['min'].to_i : humidity.to_i
              hum_max = (stats['humidity']['max'].to_i >= humidity.to_i) ? stats['humidity']['max'].to_i : humidity.to_i
              charge_avg = ( ( stats['battery_charge']['avg'].to_f * counter) + battery_charge.to_i ) / (counter+1)
              charge_min = (stats['battery_charge']['min'].to_i <= battery_charge.to_i) ? stats['battery_charge']['min'].to_i : battery_charge.to_i
              charge_max = (stats['battery_charge']['max'].to_i >= battery_charge.to_i) ? stats['battery_charge']['max'].to_i : battery_charge.to_i

              stats = { temperature: { avg: temp_avg, min: temp_min, max: temp_max} }
              stats.merge!({ humidity: { avg: hum_avg, min: hum_min, max: hum_max } })
              stats.merge!({ battery_charge: { avg: charge_avg, min: charge_min, max: charge_max} })
              stats.merge!({ counter: counter+1 })
            else
              # Thermostat Stats -  Temperature(avg, min, max), Humidity(avg, min, max), Battery Charge(avg, min, max)
              stats = { temperature: { avg: temperature, min: temperature, max: temperature} }
              stats.merge!({ humidity: { avg: humidity, min: humidity, max: humidity } })
              stats.merge!({ battery_charge: { avg: battery_charge, min: battery_charge, max: battery_charge} })
              stats.merge!({ counter: 1 })
            end
            $redis.set("thermostat_id_#{thermostat_id}_stats", stats.to_json )
          end
        end

        rescue_from ActiveRecord::RecordNotFound do |e|
          error!(status: "404", message: e.message)
        end

        rescue_from ActiveRecord::RecordInvalid do |e|
          error!(status: "422", message: e.message)
        end
      end
    end
  end
end  
