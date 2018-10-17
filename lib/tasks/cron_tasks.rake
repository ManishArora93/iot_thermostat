namespace :cron_tasks do
  desc "TODO"
  task save_readings_from_redis: :environment do
    failed_readings = {}
    # Get all the unsaved records from redis.
  	readings = $redis.keys.select {|key| key.starts_with? ("reading_id")}
    if readings.present?
      readings.each do |reading|
      	params = JSON.parse($redis.get(reading))
      	begin
          # Save the record in Database
          Reading.create!(reading_id: params["reading_id"], thermostat_id: params["thermostat_id"], temperature: params["temperature"].to_i, humidity: params["humidity"].to_i, battery_charge: params["battery_charge"].to_i)
          # Clear the record from redis structure.
          $redis.del("reading_id_#{params["reading_id"]}_#{params["thermostat_id"]}")
        rescue Exception => e
          # Keeping record of failed keys and reasons
          failed_readings["#{params["reading_id"]}_#{params["thermostat_id"]}"] << e.message
        end
      end
    end
  end
end