class CreateThermostats < ActiveRecord::Migration[5.2]
  def change
    create_table :thermostats do |t|
      t.string :thermostat_token
      t.string :location
      t.timestamps
    end
  end
end
