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
          p params
          #thermostat_id = authenticate_thermostat(params[:thermostat_token])
          Reading.where(reading_id: params[:id]).first!
        end

	      post :add_reading do
          thermostat_id = authenticate_thermostat(params[:thermostat_token])
          reading_id = generate_next_number_in_sequence
          #safe_params = clean_params(params[:attributes]).permit(:name, :description, :image_url, :price, :stock)

          #if safe_params
          Reading.create(reading_id: reading_id, thermostat_id: thermostat_id, temperature: params[:temperature].to_i, humidity: params[:humidity].to_i, battery_charge: params[:battery_charge].to_i)
          status 200 # Saved OK
	          #end
	      end
      end
    end
  end
end  

