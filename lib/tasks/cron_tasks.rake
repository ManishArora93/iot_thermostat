namespace :cron_tasks do
  desc "TODO"
  task save_readings_from_redis: :environment do
    failed_readings = {}
  	readings = $redis.keys.select {|key| key.starts_with? ("reading_id")}
    if readings.present?
      readings.each do |reading|
      	params = JSON.parse($redis.get(reading))
      	begin
          Reading.create!(reading_id: params[:reading_id], thermostat_id: params[:thermostat_id], temperature: params[:temperature].to_i, humidity: params[:humidity].to_i, battery_charge: params[:battery_charge].to_i)
          $redis.del("reading_id_#{params[:reading_id]}")
        rescue Exception => e
          failed_readings[params[:reading_id]] << e.message
        end
      end
    end
  end
end