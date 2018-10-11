class CreateReadings < ActiveRecord::Migration[5.2]
  def up
    create_table :readings do |t|
      t.references :thermostat, foreign_key: true
      t.integer :temperature
      t.integer :battery_charge
      t.integer :humidity
      t.integer :reading_id
      t.timestamps
    end
  end
  
  def down
  	drop_table :readings
  end
end
