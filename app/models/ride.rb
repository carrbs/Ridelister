# frozen_string_literal: true

# Ride Class
class Ride < ApplicationRecord
  validates :start_address, :destination_address, presence: true
  belongs_to :driver

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

  def score
    # Calculate the score of a ride in $ per hour as: (ride earnings) / (commute duration + ride duration)
  end
end
