# frozen_string_literal: true

require 'httparty'

# DirectionService is a wrapper for the Google Directions API.
class DirectionService
  include HTTParty
  class DirectionServiceError < StandardError; end

  DIRECTIONS_URL = 'https://maps.googleapis.com/maps/api/directions/json'
  GOOGLE_API_KEY = ENV['GOOGLE_DIRECTIONS_API_KEY']
  MILES_PER_METER = 0.000621371
  SECONDS_PER_MINUTE = 60.0
  MINUTES_PER_HOUR = 60.0

  def initialize(start_address, end_address)
    @start_address = start_address
    @end_address = end_address
  end

  def fetch_directions
    set_directions_from_google
    parse_distance_and_duration
  end

  # TODO: puts statement should be converted to logging statements.
  def set_directions_from_google
    puts "Fetching directions from #{@start_address} to #{@end_address}"
    @response = self.class.get(DIRECTIONS_URL,
                               query: { origin: @start_address, destination: @end_address, key: GOOGLE_API_KEY })

    return if @response.success?

    raise DirectionServiceError, "Failed to fetch directions: #{@response.code} - #{@response.body}"
  end

  def parse_distance_and_duration
    begin
      legs = @response['routes'][0]['legs'][0]
      distance = legs['distance']['value']
      duration = legs['duration']['value']
    rescue NoMethodError
      # TODO: Log the response body.
      raise DirectionServiceError, 'Unexpected response format from Google Directions API.'
    end

    distance_in_miles = distance * MILES_PER_METER
    duration_in_hours = duration / SECONDS_PER_MINUTE / MINUTES_PER_HOUR

    [distance_in_miles, duration_in_hours]
  end
end
