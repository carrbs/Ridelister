# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

addresses = [
  '7000 NE Airport Way, Portland, OR 97218',
  '4001 SW Canyon Rd, Portland, OR 97221',
  '1005 W Burnside St, Portland, OR 97209',
  '1 N Center Ct St, Portland, OR 97227',
  '1945 SE Water Ave, Portland, OR 97214'
]

addresses.permutation(2).each do |start_address, destination_address|
  Ride.create!(start_address:, destination_address:)
end

driver_addresses = [
  '111 SW 5th Ave, Portland, OR 97204',
  '1300 SW 5th Ave, Portland, OR 97201',
  '4012 SE 17th Ave, Portland, OR 97202',
  '12000 SW 49th Ave, Portland, OR 97219',
  '5000 N Willamette Blvd, Portland, OR 97203'
]

driver_addresses.each do |home_address|
  Driver.create!(home_address:)
end
