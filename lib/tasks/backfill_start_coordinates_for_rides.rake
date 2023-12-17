namespace :geocode do
  desc 'Backfill start coordinates for existing rides'
  task backfill_rides: :environment do
    Ride.find_each do |ride|
      ride.geocode
      ride.save
    end
  end
end
