class ReadingSerializer < ActiveModel::Serializer
  
  p "coming here"
  attributes :id, :thermostat_id, :temperature, :battery_charge, :reading_id, :humidity , :created_at, :updated_at
end  