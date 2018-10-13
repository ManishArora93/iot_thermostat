class Thermostat < ApplicationRecord
	has_many :readings
	validates :thermostat_token, presence: true, uniqueness: true
end
