class AddUnifiedLatitudeLongitudeIndexToRides < ActiveRecord::Migration[7.1]
  def change
    remove_index :rides, :start_latitude
    remove_index :rides, :start_longitude
    add_index :rides, %i[start_latitude start_longitude]
  end
end
