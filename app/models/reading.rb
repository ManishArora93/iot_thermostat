class Reading < ApplicationRecord
	belongs_to :thermostat
	validates :reading_id, presence: true
end
