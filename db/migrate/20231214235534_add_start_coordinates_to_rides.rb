class AddStartCoordinatesToRides < ActiveRecord::Migration[7.1]
  def change
    add_column :rides, :start_latitude, :float
    add_index :rides, :start_latitude
    add_column :rides, :start_longitude, :float
    add_index :rides, :start_longitude
  end
end
