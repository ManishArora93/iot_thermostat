# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
puts "Creating Dummy Data for Thermostat"
# For creating thermostats
data = {abc1234: "122, Bakers Street", abc1235: "123, Bakers Street", abc1236: "124, Bakers Street", abc1237: "125, Bakers Street", abc12348: "126, Bakers Street"}
data.each do |key,value|
  Thermostat.create!(thermostat_token: key, location: value)
end
puts "Thermostats created."