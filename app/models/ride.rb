# frozen_string_literal: true

# Ride Class
class Ride < ApplicationRecord
  validates :start_address, :destination_address, presence: true
  geocoded_by :start_address, latitude: :start_latitude, longitude: :start_longitude
  after_validation :geocode, if: :start_address_changed?

  # TODO: Move all the magical numbers into constants up here

  # The ride earnings is how much the driver earns by driving the ride.
  # It takes into account both the amount of time the ride is expected
  # to take and the distance. For the purposes of this exercise, it is
  # calculated as:
  # $12 + $1.50 per mile beyond 5 miles + (ride duration) * $0.70 per minute beyond 15 minutes
  def ride_earnings(ride_distance, ride_duration)
    per_mile_earnings = 1.5
    per_minute_earnings = 0.7
    total_earnings = 12

    total_earnings += [ride_distance - 5, 0].max * per_mile_earnings
    total_earnings += [ride_duration - 15, 0].max * per_minute_earnings

    total_earnings
  end

  def fetch_ride(drivers_home_address)
    ride_distance, ride_duration = fetch_directions(start_address, destination_address)
    commute_distance, commute_duration = fetch_directions(drivers_home_address, start_address)
    score = score(ride_distance, ride_duration, commute_duration)

    # TODO: Discuss the need for the commute, and score.
    #       I put them in to verify as I was working through the exercise.
    {
      score:,
      ride_distance:,
      ride_duration:,
      commute_distance:,
      commute_duration:
    }
  end

  private

  # Calculates the score of a ride in $ per hour as:
  # (ride earnings) / (commute duration + ride duration).
  def score(ride_distance, ride_duration, commute_duration)
    # TODO: make this edge case be error handling instead of back-of-napkin math.
    total_duration = (commute_duration + ride_duration).zero? ? 0.1 : commute_duration + ride_duration

    earnings = ride_earnings(ride_distance, ride_duration)
    (earnings.to_f / total_duration).round(2)
  end

  # NOTE: Cache length could be adjusted, one minute was useful for testing.
  def fetch_directions(start_address, end_address)
    Rails.cache.fetch("#{start_address}/#{end_address}/directions", expires_in: 1.minutes) do
      DirectionService.new(start_address, end_address).fetch_directions
    end
  rescue DirectionService::DirectionServiceError => e
    raise e
  end
end
