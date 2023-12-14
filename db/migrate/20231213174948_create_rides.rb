class CreateRides < ActiveRecord::Migration[7.1]
  def change
    create_table :rides do |t|
      t.string :start_address
      t.string :destination_address

      t.timestamps
    end
  end
end
