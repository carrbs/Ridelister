# Description: Driver model
class Driver < ApplicationRecord
  validates :home_address, presence: true
  has_many :scheduled_rides
  has_many :rides, through: :scheduled_rides

  def commute_distance
    # Calculate the driving distance from the driver's home address to the start of the ride
  end

  def commute_duration
    # Calculate the amount of time it is expected to take to drive the commute distance
  end

  def ride_distance
    # Calculate the driving distance from the start address of the ride to the destination address
  end

  def ride_duration
    # Calculate the amount of time it is expected to take to drive the ride distance
  end

  def ride_earnings
    # Calculate the ride earnings
  end
end

# Driver model
class Driver < ApplicationRecord
  validates :home_address, presence: true
  has_many :rides
end
