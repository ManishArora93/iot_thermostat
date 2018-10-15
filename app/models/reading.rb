class Reading < ApplicationRecord
	belongs_to :thermostat
	["reading_id", "thermostat_id", "temperature", "battery_charge", "humidity"].each do |attribute|
    validates attribute.to_sym, presence: true
  end
end
