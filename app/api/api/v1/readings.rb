module API  
	module V1
		class Readings < Grape::API
			include API::V1::Default
			resource :readings do
				#desc "Return all readings"
				#get "", root: :readings do
					#Reading.all
				#end

				desc "Return a particular reading"
				#params do
					#use :thermostat_token, type: String, desc: 'Authenticate Household token'
					#requires :id, type: String, desc: "Reading ID of the reading"
				#end
				get ":id", root: "reading" do
					if $redis.get("reading_id_#{params[:id]}").present?
						JSON.parse($redis.get("reading_id_#{params[:id]}")) 
					else           
						#thermostat_id = authenticate_thermostat(params[:thermostat_token])
						Reading.where(reading_id: params[:id]).first!
					end
				end

				post :add_reading do
					if %i[thermostat_token temperature battery_charge humidity].all? {|s| params.key? s}
						thermostat_id = authenticate_thermostat(params[:thermostat_token])
						reading_id = generate_next_number_in_sequence
						params[:reading_id] = reading_id
						params[:thermostat_id] = thermostat_id
						params.delete("thermostat_token".to_sym)
						params.each {|k,v| v.to_i}
						@reading = Reading.new
						@reading.assign_attributes(params)
						if @reading.valid?
							#safe_params = clean_params(params[:attributes]).permit(:name, :description, :image_url, :price, :stock)
							$redis.set("reading_id_#{reading_id}", params.to_json)
							thermostat_data = $redis.get("thermostat_id_#{thermostat_id}")
							if thermostat_data.present?
								$redis.set("thermostat_id_#{thermostat_id}", thermostat_data + "," + reading_id)
							else
								$redis.set("thermostat_id_#{thermostat_id}", reading_id)
							end
							#if safe_params
							#Reading.create(reading_id: reading_id, thermostat_id: thermostat_id, temperature: params[:temperature].to_i, humidity: params[:humidity].to_i, battery_charge: params[:battery_charge].to_i)
							status 200 # Saved OK
								#end
						else
							status 400 # Bad request
						end
					else
            status 400 # Bad request
					end
				end
			end
			resource :thermostats do
				get ":id", root: "thermostat" do
					redis_reading_ids = JSON.parse($redis.get("thermostat_id_#{params[:id]}")).split(",")
					reading_data = []
					if redis_reading_ids.present?
						redis_reading_ids.each do |reading_id|
              redis_data = JSON.parse($redis.get("reading_id_#{reading_id}"))
              reading_data << redis_data
            end
          end
					data_from_database = Thermostat.where(id: params[:id]).readings
					
          
				end
		  end
		end
	end
end  

