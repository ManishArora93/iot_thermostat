class ThermostatSerializer < ActiveModel::Serializer
  attributes :id, :thermostat_token, :location
  has_many :readings
end
