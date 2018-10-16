module API  
	module V1
		class Readings < Grape::API
			include API::V1::Default
			resource :readings do
				desc "Return a particular reading"
				get ":id", root: "reading" do
					begin
	          thermostat_id = authenticate_thermostat(headers["Authorisation-Token"])
            # Check data in redis
		        redis_response = $redis.get("reading_id_#{params[:id]}_#{thermostat_id}")
						if redis_response.present?
							reading = JSON.parse(redis_response)
						else
              begin
                # Check in DB, if not found in Redis.           
							  reading = Reading.where(reading_id: params[:id], thermostat_id: thermostat_id).first!
              rescue 
                throw_error(404, "Record not found")
              end
						end
						{reading: reading}
					rescue
						throw_error(500, 'Internal Server Error')
					end
				end
        
        desc "Saving Readings for a thermostat and saving statistics"
				post :add_reading do
					begin
						if %i[temperature battery_charge humidity].all? {|s| params.key? s}
							thermostat_token = headers["Authorisation-Token"]
							thermostat_id = authenticate_thermostat(thermostat_token)
							reading_id = generate_next_number_in_sequence(thermostat_id)
							params[:reading_id] = reading_id
							params[:thermostat_id] = thermostat_id
							params.delete("thermostat_token".to_sym)
							params.each do |k,v|
								throw_error(400, 'Bad Request - Data Inappropriate') unless v !~ /\D/
						  end
              # Save data in redis
							$redis.set("reading_id_#{reading_id}_#{thermostat_id}", params.to_json)
              # Calculate the statistics for particular thermostat
              calculate_thermostat_stats(thermostat_id, params[:temperature], params[:humidity], params[:battery_charge] )
						  data = {reading_id: reading_id} # Saved OK
						else
							throw_error(400, 'Bad Request - Missing Params')
						end
					rescue
					  throw_error(500, 'Internal Server Error')
					end
				end
			end

			resource :thermostats do
			  get ":id", root: "thermostat" do
			  	begin 
				  	thermostat_id = authenticate_thermostat(headers["Authorisation-Token"])
            # Return error if the passed thermostat_id doesn't match with the token passed in headers
				  	throw_error(403, "Forbidden") if params[:id].to_i != thermostat_id
            # Return data from Redis
					  stat_data = $redis.get("thermostat_id_#{thermostat_id}_stats")
				  	if stat_data.present?
					    stats = JSON.parse(stat_data)
					    stats.delete('counter')
					    {stats: stats}
					  else
					  	throw_error(404, "No Data Present for thermostat #{headers["Authorisation-Token"]}")
					  end
					rescue
						throw_error(500, 'Internal Server Error')
					end
			  end
			end
		end
	end
end  

