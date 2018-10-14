class ReadingSerializer < ActiveModel::Serializer
  attributes :id, :temperature, :battery_charge, :humidity, :reading_id, :thermostat_id
  belongs_to :thermostat
end
