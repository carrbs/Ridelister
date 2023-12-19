# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Source: https://www.pps.net/Page/2142
portland_high_school_addresses = [
  '5405 SE Woodward St, Portland, OR 97206',
  '3400 SE 26th Ave, Portland, OR 97202',
  '3905 SE 91st Ave Portland, OR 97266',
  '2245 NE 36th Avenue, Portland, OR 97212',
  '1151 SW Vermont St, Portland, OR 97219'
]

portland_high_school_addresses.permutation(2).each do |start_address, destination_address|
  Ride.create!(start_address:, destination_address:)
end

# Source: also https://www.pps.net/Page/2142
driver_addresses = [
  '2421 SE Orange Ave, Portland, OR 97214',
  '2425 SW Vista St Portland, OR 97201',
  '2732 NE Fremont St, Portland, OR 97212',
  '5800 SE Division St, Portland, OR 97206',
  '620 N Fremont St Portland, OR 97227'
]

driver_addresses.each do |home_address|
  Driver.create!(home_address:)
end
