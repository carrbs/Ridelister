# frozen_string_literal: true

require 'httparty'

# DirectionsService
class DirectionService
  include HTTParty
  DIRECTIONS_URL = 'https://maps.googleapis.com/maps/api/directions/json'
  GOOGLE_API_KEY = ENV['GOOGLE_DIRECTIONS_API_KEY']

  def initialize(start_address, end_address)
    @start_address = start_address
    @end_address = end_address
  end

  def fetch_directions
    puts "Fetching directions from #{@start_address} to #{@end_address}"
    response = self.class.get(DIRECTIONS_URL,
                              query: { origin: @start_address, destination: @end_address, key: GOOGLE_API_KEY })

    legs = response['routes'][0]['legs'][0]
    distance = legs['distance']['value']
    duration = legs['duration']['value']

    distance_in_miles = distance * 0.000621371
    duration_in_minutes = duration / 60.0

    [distance_in_miles, duration_in_minutes]
  end
end
