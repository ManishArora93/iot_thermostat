module API  
	module V1
		class Readings < Grape::API
			include API::V1::Default
			resource :readings do
				desc "Return a particular reading"
				get ":id", root: "reading" do
          thermostat_id = authenticate_thermostat(headers["Authorisation-Token"])
          begin
	          redis_response = $redis.get("reading_id_#{params[:id]}_#{thermostat_id}")
	        rescue
	        	throw_error(503, 'Service not Available')
	        end
					if redis_response.present?
						reading = JSON.parse(redis_response)
					else           
						reading = Reading.where(reading_id: params[:id], thermostat_id: thermostat_id).first!
					end
					{reading: reading}
				end
        
        desc "Saving Readings for a thermostat and saving statistics"
				post :add_reading do
					if %i[temperature battery_charge humidity].all? {|s| params.key? s}
						thermostat_token = headers["Authorisation-Token"]
						thermostat_id = authenticate_thermostat(thermostat_token)
						reading_id = generate_next_number_in_sequence(thermostat_id)
						params[:reading_id] = reading_id
						params[:thermostat_id] = thermostat_id
						params.delete("thermostat_token".to_sym)
						params.each {|k,v| v.to_i}
						@reading = Reading.new
						@reading.assign_attributes(params)
						if @reading.valid?
							begin
								$redis.set("reading_id_#{reading_id}_#{thermostat_id}", params.to_json)
	              calculate_thermostat_stats(thermostat_id, params[:temperature], params[:humidity], params[:battery_charge] )
							  data = {reading_id: reading_id} # Saved OK
							rescue
								throw_error(503, 'Service not Available')
							end
						else
							throw_error(400, 'Bad Request - Data Inappropriate')
						end
					else
						throw_error(400, 'Bad Request - Missing Params')
					end
				end
			end

			resource :thermostats do
			  get ":id", root: "thermostat" do
			  	thermostat_id = authenticate_thermostat(headers["Authorisation-Token"])
			  	throw_error(403, "Forbidden") if params[:id].to_i != thermostat_id
			  	begin
				  	stat_data = $redis.get("thermostat_id_#{thermostat_id}_stats")
				  rescue
				  	throw_error(503, 'Service not Available')
				  end
			  	if stat_data.present?
				    stats = JSON.parse(stat_data)
				    stats.delete('counter')
				    {stats: stats}
				  else
				  	throw_error(404, "No Data Present for thermostat #{headers["Authorisation-Token"]}")
				  end
			  end
			end
		end
	end
end  

